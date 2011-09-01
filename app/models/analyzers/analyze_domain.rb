require 'page.rb'
require 'source.rb'
require 'feature.rb'
require 'analyzers/matcher.rb'

module Analyzers
  class AnalyzeDomain
    @queue = 'high'

    DOWNLOAD_TIMEOUT = 10
    MASK_ERRORS = ["OpenURI::HTTPError", "Timeout::Error", "RuntimeError", "SocketError",
                   "Errno::EHOSTUNREACH", "Errno::ECONNRESET", "Errno::ECONNREFUSED", "Errno::ETIMEDOUT",
                   "EOFError"]

    def self.perform(domain_id)
      analyze(Domain.find(domain_id), 0)
    end

    def self.daemon(thread_count = 100)
      if thread_count > 0
        Thread.abort_on_exception = true

        queue = SizedQueue.new(thread_count)

        threads = []
        thread_count.times { |i|
          threads << Thread.new(i) { |id|
            while true
              analyze(queue.shift, id)
            end
          }
        }

        while true
          Domain.to_be_analyzed.find_each { |record|
            queue << record
          }

          sleep 5
        end
      else
        Domain.to_be_analyzed.find_each { |record|
          analyze(record)
        }
      end
    end

    def self.analyze(domain, id = 0)
      domain.analyze { |domain|
        begin
          url, body, headers, cached = download(domain)

          begin
            domain.create_page(:url => url)
          rescue ActiveRecord::RecordNotUnique
            domain.page = Page.find_by_url(url)
          end

          unless Rails.env.production? or cached
            domain.page.build_source unless domain.page.source
            domain.page.source.headers = headers.to_yaml
            domain.page.source.body = body
          end

          matcher = Matcher.new
          result = matcher.match(headers, body)
          domain.page.server = result[:server]
          domain.page.engine = result[:engine]
          domain.page.doctype = result[:doctype]
          domain.page.framework = result[:framework]
          domain.page.features.clear
          for feature in result[:features]
            domain.page.features.build :name => feature
          end

          domain.page.save

          Rails.logger.info "#{id}: #{domain.name} => #{url}"
        rescue StandardError => err
          if MASK_ERRORS.include?(err.class.name)
            Rails.logger.info "#{id}: #{domain.name} => #{err.message}"
          else
            Rails.logger.warn "#{id}: #{domain.name} => #{err.message} (#{err.class})"
          end
        end
      }
    end

    private

    def self.download(domain)
      if not Rails.env.production? and domain.page_id and domain.page.source
        url = domain.page.url
        headers = YAML::load(domain.page.source.headers)
        body = domain.page.source.body

        [url, body, headers, true]
      else
        open("http://www." + domain.name,
                   :read_timeout => DOWNLOAD_TIMEOUT, :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE) { |file|
          url = file.base_uri.to_s
          headers = file.meta
          body = file.read

          return [url, body, headers, false]
        }
      end
    end
  end
end
