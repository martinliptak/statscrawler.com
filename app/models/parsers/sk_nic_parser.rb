require 'open-uri'

module Parsers
  class SkNicParser < BaseParser

    SK_NIC_LIST_URL = "https://www.sk-nic.sk/documents/domeny_1.txt.gz"

    @queue = 'low'
    def self.perform
      Rails.logger.info "#{Time.now} Downloading SK-NIC domains"
      open(SK_NIC_LIST_URL, :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE) { |file|
        ActiveRecord::Base.connection.execute("CREATE TEMPORARY TABLE temp_domains (
          name VARCHAR(255) PRIMARY KEY
        ) COLLATE utf8_unicode_ci")
        
        Rails.logger.info "#{Time.now} Gunzipping domain list"
        Tempfile.open("sk_nic.csv.gz", :external_encoding => Encoding::ASCII_8BIT) { |temp_gz|
          temp_gz.write(file.read)
          temp_gz.flush
          
          Rails.logger.info "#{Time.now} Importing domain list"
          Tempfile.open("sk_nic.csv") { |temp|
            temp.write(Zlib::GzipReader.open(temp_gz).read)
            temp.flush
            
            ActiveRecord::Base.connection.execute("LOAD DATA LOCAL INFILE '#{temp.path}'
              INTO TABLE temp_domains
              FIELDS TERMINATED BY ';'
              IGNORE 11 LINES
              (name)
            ")
          }
        }
        
        Rails.logger.info "#{Time.now} Destroying SK-NIC domains"
        Domain.find_by_sql("SELECT * FROM domains d
                                WHERE tld = 'sk' AND NOT EXISTS (SELECT * FROM temp_domains t WHERE t.name = d.name)").each { |domain|
          domain.destroy
        }
        
        Rails.logger.info "#{Time.now} Adding SK-NIC domains"
        Domain.connection.execute("SELECT name FROM temp_domains t
                                               WHERE NOT EXISTS (SELECT * FROM domains d 
                                                                 WHERE d.name = t.name)").each { |result|
          Domain.create(:name => result[0])
        }
        
        ActiveRecord::Base.connection.execute("DROP TEMPORARY TABLE temp_domains")
      }  
    end
  end
end
