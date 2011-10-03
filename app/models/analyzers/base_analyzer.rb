module Analyzers
  class BaseAnalyzer
    GEO_IP = GeoIP.new(Rails.root.join("vendor/GeoLiteCity.dat"))
    DNS = Resolv::DNS.new

    DOWNLOAD_TIMEOUT = 60
    MASK_ERRORS = []

    def self.analyze(domain, id = 0)
      domain.analyze { |domain|
        begin
          analyze_location(domain)
          analyze_page(domain)

          Rails.logger.info "#{id}: #{domain.name}"
        rescue NoMethodError => err
          Rails.logger.warn "#{id}: #{domain.name} => #{err.message} (#{err.class})"
          retry
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
        timeout(DOWNLOAD_TIMEOUT) {
          open(domain.url, :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE) { |file|
            url = file.base_uri.to_s
            headers = file.meta
            body = file.read

            return [url, body, headers, false]
          }
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

      matcher = Matcher.new(headers, body)
      result = matcher.match
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
      ip = DNS.getaddress(domain.name).to_s

      ress = DNS.getresources domain.name, Resolv::DNS::Resource::IN::AAAA
      domain.ipv6 = (ress.present? and ress.any?)

      if ip
        begin
          domain.create_location(:ip => ip)
        rescue ActiveRecord::RecordNotUnique
          domain.location = Location.find_by_ip(ip)
        end

        g = GEO_IP.city(ip)
        if g
            domain.location.country = g.country_name
            domain.location.city = g.city_name
            domain.location.city = "Praha" if domain.location.city == "Prague"
            domain.location.longitude = g.longitude
            domain.location.latitude = g.latitude
            domain.location.save
        end
      end
    end
  end
end
