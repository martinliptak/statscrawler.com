require 'open-uri'

module Parsers
  class DmozParser
    DMOZ_DUMP_URL='http://rdf.dmoz.org/rdf/content.rdf.u8.gz'

    @queue = 'low'

    def self.perform
      count = 0
      Rails.logger.info "#{Time.now} Importing from DMOZ dump"
      open(DMOZ_DUMP_URL) { |file|
        p 'opened'
        gz = Zlib::GzipReader.new(file)
        p 'reader created'
        gz.each_line { |line|
          if line =~ %r{http://([^/]*)}
            p "line #{count += 1}"
            Domain.create_from_list('dmoz', $1)
          end
        }
        gz.close
      }
    end
  end
end