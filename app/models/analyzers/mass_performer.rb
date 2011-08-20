require 'open-uri'

class ActiveRecord::Base

  def self.each_in_thread(thread_count)
    if thread_count > 0 and not Rails.env.test?
      Thread.abort_on_exception = true

      queue = SizedQueue.new(thread_count)

      threads = []
      thread_count.times { |i|
        threads << Thread.new(i) { |id|
          while true
            yield(id, queue.shift)
          end
        }
      }

      find_each { |record|
        queue << record
      }
    else
      find_each { |record|
        yield(0, record)
      }
    end
  end
end

module Analyzers
  class MassPerformer
    DOWNLOAD_TIMEOUT = 10

    @queue = 'high'
    
    def self.perform
      mask_errors = ["OpenURI::HTTPError", "Timeout::Error", "RuntimeError", "SocketError",
                     "Errno::EHOSTUNREACH", "Errno::ECONNRESET", "Errno::ECONNREFUSED", "Errno::ETIMEDOUT",
                     "EOFError"]
      page_mutex = Mutex.new
      pages = {}

      Domain.where(:analyzed_at => nil).each_in_thread(100) { |id, domain|
        domain.analyze { |domain|
          begin
            url, body, meta, cached = download(domain)

            page_mutex.synchronize {
              unless pages[url]
                begin
                  domain.create_page(:url => url)
                rescue ActiveRecord::RecordNotUnique
                  domain.page = Page.find_by_url(url)
                end

                pages[url] = domain.page.id
              end
            }

            unless domain.page
              domain.page_id = pages[url]
            else
              unless Rails.env.production? or cached
                domain.page.build_source
                domain.page.source.headers = meta.to_yaml
                domain.page.source.body = body
              end

              domain.page.save
            end

            Rails.logger.info "#{id}: #{domain.name} => #{url}"
          rescue StandardError => err
            if mask_errors.include?(err.class.name)
              Rails.logger.info "#{id}: #{domain.name} => #{err.message}"
            else
              Rails.logger.warn "#{id}: #{domain.name} => #{err.message} (#{err.class})"
            end
          end
        }
      }
    end

    private

    def self.download(domain)
      if not Rails.env.production? and domain.page_id and domain.page.source
        url = domain.page.url
        meta = YAML::load(domain.page.source.meta)
        body = domain.page.source.body

        [url, body, meta, true]
      else
        open("http://www." + domain.name,
                   :read_timeout => DOWNLOAD_TIMEOUT, :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE) { |file|
          url = file.base_uri.to_s
          meta = file.meta
          body = file.read

          return [url, body, meta, false]
        }
      end
    end

    def self.cache_source(domain)

    end
  end
end
