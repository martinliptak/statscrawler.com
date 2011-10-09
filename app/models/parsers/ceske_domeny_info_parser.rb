require 'open-uri'

module Parsers
  class CeskeDomenyInfoParser < BaseParser

    @queue = 'low'
    def self.perform
      Rails.logger.info "#{Time.now} Parsing czech domains"
      for letter in (1..9).to_a + ('A'..'Z').to_a

        Rails.logger.info "#{Time.now} Parsing '#{letter}' domains"
        for page in (1..10_000)
          continue = false

          open("http://www.ceskedomeny.info/#{letter}?page=#{page}") { |file|
            doc = Nokogiri::HTML(file.read)
            anchors = doc.css('.left table a')
            if anchors.any?
              for a in anchors
                Domain.find_or_create_by_name(a.text.sub('www.', '').tr('/', ''))
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