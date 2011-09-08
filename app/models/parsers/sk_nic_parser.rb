require 'open-uri'

module Parsers
  class SkNicParser < BaseParser

    SK_NIC_LIST_URL = "https://www.sk-nic.sk/documents/domeny_1.txt.gz"

    @queue = 'parser'
    def self.perform
      Rails.logger.info "#{Time.now} Downloading SK-NIC domains"
      open(SK_NIC_LIST_URL, :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE) { |file|
        ActiveRecord::Base.connection.execute("CREATE TEMPORARY TABLE temp_domains (
          name VARCHAR(255) PRIMARY KEY
        ) COLLATE utf8_unicode_ci")
        
        Rails.logger.info "#{Time.now} Gunzipping and importing domain list"
        Tempfile.open("sk_nic.csv.gz", :external_encoding => Encoding::ASCII_8BIT) { |temp_gz|
          temp_gz.write(file.read)
          temp_gz.flush
          
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
        ListDomain.find_by_sql("SELECT l.* FROM list_domains l 
                                JOIN domains d ON d.id = l.domain_id AND l.list = 'sk_nic'
                                WHERE NOT EXISTS (SELECT * FROM temp_domains t WHERE t.name = d.name)").each { |list_domain|
          list_domain.destroy
        }
        
        Rails.logger.info "#{Time.now} Adding SK-NIC domains"
        ActiveRecord::Base.connection.execute("SELECT name FROM temp_domains t 
                                               WHERE NOT EXISTS (SELECT * FROM domains d 
                                                                 JOIN list_domains l ON d.id = l.domain_id 
                                                                 WHERE d.name = t.name AND l.list = 'sk_nic')").each { |result|
          Domain.create_from_list('sk_nic', result[0])
        }
        
        ActiveRecord::Base.connection.execute("DROP TEMPORARY TABLE temp_domains")
      }  
    end
  end
end
