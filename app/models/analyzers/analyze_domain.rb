require 'resolv.rb'

module Analyzers
  class AnalyzeDomain
    @queue = 'analyzer'

    GEO_IP = GeoIP.new("vendor/GeoLiteCity.dat")

    DOWNLOAD_TIMEOUT = 10
    MASK_ERRORS = ["OpenURI::HTTPError", "Timeout::Error", "RuntimeError", "SocketError",
                   "Errno::EHOSTUNREACH", "Errno::ECONNRESET", "Errno::ECONNREFUSED", "Errno::ETIMEDOUT",
                   "EOFError"]

    def self.perform(domain_id)
      analyze(Domain.find(domain_id), 0)
    end

    def self.daemon(thread_count = 50)

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
          analyze_page(domain)
          analyze_location(domain)

          Rails.logger.info "#{id}: #{domain.name}"
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
        open(domain.url,
             :read_timeout => DOWNLOAD_TIMEOUT,
             :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE) { |file|
          url = file.base_uri.to_s
          headers = file.meta
          body = file.read

          return [url, body, headers, false]
        }
      end
    end

    def self.analyze_page(domain)
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
      domain.page.description = result[:description]
      domain.page.keywords = result[:keywords]
      domain.page.server = result[:server]
      domain.page.engine = result[:engine]
      domain.page.doctype = result[:doctype]
      domain.page.framework = result[:framework]
      domain.page.features.clear
      for feature in result[:features]
        domain.page.features.build :name => feature
      end
      domain.page.save
    end

    def self.analyze_location(domain)
      ip = Resolv.getaddress(domain.name)
      Resolv::DNS.open do |dns|
        ress = dns.getresources domain.name, Resolv::DNS::Resource::IN::AAAA
        domain.ipv6 = (ress.present? and ress.any?)
      end

      begin
        domain.create_location(:ip => ip)
      rescue ActiveRecord::RecordNotUnique
        domain.location = Location.find_by_ip(ip)
      end

      g = GEO_IP.city(ip)
      domain.location.country = g.country_name
      domain.location.city = g.city_name
      domain.location.city = "Praha" if domain.location.city == "Prague"
      domain.location.longitude = g.longitude
      domain.location.latitude = g.latitude
      domain.location.save
    end
  end
end
