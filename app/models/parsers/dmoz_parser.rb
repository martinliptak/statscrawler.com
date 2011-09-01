require 'open-uri'

module Parsers
  class DmozParser
    @queue = 'low'

    def self.perform
      open("/media/data/Martin/Stahovania/content.rdf.u8") { |file|
        file.each_line { |line|
          if line =~ %r{http://([^/]*)}
            Domain.create_from_list('dmoz', $1)
          end
        }
      }
    end
  end
end