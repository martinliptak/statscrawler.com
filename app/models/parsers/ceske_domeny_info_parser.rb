require 'open-uri'

module Parsers
  class CeskeDomenyInfoParser < BaseParser

    @queue = 'low'
    def self.perform
      for letter in (1..9).to_a + ('A'..'Z').to_a
        for page in (1..10_000)
          continue = false

          open("http://www.ceskedomeny.info/#{letter}?page=#{page}") { |file|
            doc = Nokogiri::HTML(file.read)
            anchors = doc.css('.left table a')
            if anchors.any?
              for a in anchors
                Domain.create_from_list('cz', a.text.sub('www.', '').tr('/', ''))
              end
              continue = true
            end
          } rescue OpenURI::HTTPError

          break unless continue
        end
      end
    end
  end
end