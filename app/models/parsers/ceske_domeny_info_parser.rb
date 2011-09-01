require 'open-uri'

module Parsers
  class CeskeDomenyInfoParser
    @queue = 'low'

    def self.perform
      for page in (1..1_000_000)
        begin
          open("http://www.ceskedomeny.info/?page=#{page}") { |file|
            doc = Nokogiri::HTML(file.read)
            for a in doc.css('.left table a')
              Domain.create_from_list('cz', a.text.sub('www.', '').tr('/', ''))
            end
          }
        rescue OpenURI::HTTPError
          break
        end
      end
    end
  end
end