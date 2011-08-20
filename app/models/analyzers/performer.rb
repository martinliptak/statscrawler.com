require 'open-uri'

module Analyzers
  class Performer
    @queue = 'high'
    
    def self.perform(domain_id)
      Domain.find(domain_id).analyze { |domain|
        open("http://www." + domain.name, :read_timeout => 10, :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE) { |file|
          domain.build_page unless domain.page
          page = domain.page
          unless Rails.env.production?
            page.build_source unless page.source
            page.source.headers = file.meta.to_yaml
            page.source.body = file.read
          end
        }
      }
    end
  end
end
