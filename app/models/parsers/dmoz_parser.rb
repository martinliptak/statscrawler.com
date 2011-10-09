module Parsers
  class DmozParser < BaseParser

    DMOZ_DUMP_URL='http://rdf.dmoz.org/rdf/content.rdf.u8.gz'

    @queue = 'low'
    def self.perform
      Rails.logger.info "#{Time.now} Importing from DMOZ dump"
      open(DMOZ_DUMP_URL) { |file|
        gz = Zlib::GzipReader.new(file)
        gz.each_line { |line|
          if line =~ %r{http://([^/]*)}
            Domain.find_or_create_by_name($1)
          end
        }
        gz.close
      }
    end
  end
end