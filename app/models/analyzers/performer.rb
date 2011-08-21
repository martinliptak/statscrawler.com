require 'open-uri'

module Analyzers
  class Performer
    @queue = 'high'
    
    def self.perform(domain_id)
      Domain.find(domain_id).analyze { |domain|
        open("http://www." + domain.name, :read_timeout => 10, :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE) { |file|
          url = file.base_uri.to_s
          body = file.read
          headers = file.meta

          begin
            domain.create_page(:url => url)
          rescue ActiveRecord::RecordNotUnique
            domain.page = Page.find_by_url(url)
          end

          unless Rails.env.production?
            domain.page.build_source unless domain.page.source
            domain.page.source.headers = headers.to_yaml
            domain.page.source.body = body
          end

          analyzer = Analyzer.new(headers, body)
          result = analyzer.run

          domain.page.server = result[:server]
          domain.page.engine = result[:engine]
          domain.page.doctype = result[:doctype]
          domain.page.framework = result[:framework]
          domain.page.features.clear
          for feature in result[:features]
            domain.page.features.build :name => feature
          end
          domain.page.save
        }
      }
    end
  end
end
