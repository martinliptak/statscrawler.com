module Analyzers
  class BaseAnalyzer
    GEO_IP = GeoIP.new(Rails.root.join("vendor/GeoLiteCity.dat"))
    DNS = Resolv::DNS.new

    DOWNLOAD_TIMEOUT = 30

    def self.analyze(domain, id = 0)
      ActiveRecord::Base.logger = Logger.new(STDOUT)
      ActiveRecord::Base.logger.level = 0
    
      domain.analyze { |domain|
        attempts = 0
        begin
          attempts += 1
          
          analyze_location(domain)
          analyze_page(domain)

          Rails.logger.info "#{id}: #{domain.name}"
        rescue NoMethodError => err
          Rails.logger.warn "#{id}: #{domain.name} => #{err.message} (#{err.class})"
          
          if attempts < 5
            retry 
          else
            raise err
          end
        rescue StandardError => err
          Rails.logger.warn "#{id}: #{domain.name} => #{err.message} (#{err.class})"
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
        Rails.logger.info "#{Time.now}: Downloading"
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

      Rails.logger.info "#{Time.now}: Creating page"
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

      Rails.logger.info "#{Time.now}: Matching"
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
      
      Rails.logger.info "#{Time.now}: Saving"
      domain.page.save
    end

    def self.analyze_location(domain)
      Rails.logger.info "#{Time.now}: Resolving"
      ip = DNS.getaddress(domain.name).to_s

      Rails.logger.info "#{Time.now}: Resolving IPv6"
      ress = DNS.getresources domain.name, Resolv::DNS::Resource::IN::AAAA
      domain.ipv6 = (ress.present? and ress.any?)

      if ip
        Rails.logger.info "#{Time.now}: Creating location"
        domain.location = Location.find_or_create_by_ip(ip)

        Rails.logger.info "#{Time.now}: Geoiping"
        g = GEO_IP.city(ip)
        if g
            domain.location.country = g.country_name
            domain.location.city = g.city_name
            domain.location.city = "Praha" if domain.location.city == "Prague"
            domain.location.longitude = g.longitude
            domain.location.latitude = g.latitude
            
            Rails.logger.info "#{Time.now}: Saving location"
            domain.location.save
        end
      end
    end
  end
end
