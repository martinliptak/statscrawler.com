require "whois"
require "page_rankr"

COUNTRIES = {
    'Global' => ['com', 'org', 'net', 'edu', 'info', 'biz', 'gov'],
    'German' => ['de', 'ch', 'at'],
    'Italian' => 'it',
    'French' => 'fr',
    'Czech' => 'cz',
    'Russian' => 'ru',
    'Japanese' => 'jp'
}

class DomainsController < ApplicationController
  include DomainsHelper

  before_filter :set_params_tld, :except => :search
  before_filter :set_markers, :only => :index

  caches_action :index, :layout => false, :cache_path => Proc.new { |controller|
    "domains_index_#{controller.params[:tld]}"
  }
  caches_action :countries, :layout => false

  def index
    @domains = Domain.where(:tld => @tld).analyzed

    @distribution = {}

    @distribution[:framework] = distribution(Domain.connection.execute("
      select framework, count(*) from pages
        join domains on page_id = pages.id and tld in #{@tld_set}
        where framework is not null
        group by framework order by count(*) desc"), :framework)

    @distribution[:feature] = distribution(Domain.connection.execute("
      select features.name, count(*) from features
        join pages on features.page_id = pages.id
        join domains on domains.page_id = pages.id and tld in #{@tld_set}
        group by name order by count(*) desc"), :feature)

    for type in [:server, :engine, :doctype]
      @distribution[type] = distribution(Domain.connection.execute("
        select #{type}, count(*) from pages
          join domains on page_id = pages.id and tld in #{@tld_set}
          group by #{type} order by count(*) desc"), type, @domains.count / 100)
    end

    @html5 = Domain.connection.execute("
      select count(*) from pages
        join domains on page_id = pages.id and tld in #{@tld_set}
        where doctype = 'html' ").first.first

    @distribution[:ipv6] = Domain.connection.execute("
      select if(ipv6, 'Yes', 'No'), count(*) from domains
        where ipv6 is not null and tld in #{@tld_set}
        group by ipv6 order by count(*) desc")

    @distribution[:country] = distribution(Domain.connection.execute("
      select country, count(*) from locations
        join domains on locations.id = domains.location_id and tld in #{@tld_set}
        group by country order by count(*) desc"), :country, @domains.count / 200)

    @distribution[:city] = distribution(Domain.connection.execute("
      select city, count(*) from locations
        join domains on locations.id = domains.location_id and tld in #{@tld_set}
        where city <> ' '
        group by city order by count(*) desc limit 12"), :city)

    @markers = Domain.connection.execute("
      select longitude, latitude, count(*), city from locations
        join domains on locations.id = domains.location_id and tld in #{@tld_set}
        where longitude is not null and latitude is not null and city <> ' '
        group by longitude, latitude order by count(*) desc limit 100").map { |marker|
      {
        :latitude => marker[1],
        :longitude => marker[0],
        :title => marker[3],
        :icon => marker_icon(marker[2]),
        :html => "<b>#{marker[3]}</b><br/>
                    <a href=#{url_for(search_domains_path(:city => marker[3], :tld => params[:tld]))}>#{pluralize(marker[2], 'domain')}</a>"
      }
    }
  end

  def show
    @domain = Domain.find_by_name(decode_domain_name(params[:id]))
    @title = "Domain #{@domain.name}"
    if @domain.location
      domains = Domain.includes(:location).where('locations.ip' => @domain.location.ip).count

      @markers = [{
          :latitude => @domain.location.latitude,
          :longitude => @domain.location.longitude,
          :title => @domain.location.ip,
          :icon => marker_icon(domains),
          :html => "<b>#{@domain.location.ip}</b><br/>
                      <a href=#{url_for(search_domains_path(:ip => @domain.location.ip))}>
                        #{pluralize(domains, 'domain')}</a>"
      }]
    end
  rescue ActiveRecord::RecordNotFound
    render :action => "410", :status => '410 Gone'
  end

  def search
    tables = []
    where = {}
    like = {}

    unless params[:name].blank?
      like = ["domains.name LIKE ?", "#{params[:name]}%"]
    end

    unless params[:server].blank?
      tables << :page
      where['pages.server'] = params[:server]
    end
    unless params[:engine].blank?
      tables << :page
      where['pages.engine'] = params[:engine]
    end
    unless params[:doctype].blank?
      tables << :page
      where['pages.doctype'] = params[:doctype]
    end
    unless params[:framework].blank?
      tables << :page
      where['pages.framework'] = params[:framework]
    end
    unless params[:feature].blank?
      tables << { :page => :features }
      where['features.name'] = params[:feature]
    end

    unless params[:ip].blank?
      tables << :location
      where['locations.ip'] = params[:ip]
    end
    unless params[:city].blank?
      tables << :location
      where['locations.city'] = params[:city]
    end
    unless params[:country].blank?
      tables << :location
      where['locations.country'] = params[:country]
    end

    if params[:tld].present?
      set_params_tld
      where['domains.tld'] = @tld
    end

    @domains = Domain.page(params[:page]).includes(tables.uniq).where(where).where(like)
    @domains = @domains.order('domains.name') if params[:name].present?

    if @domains.count == 1 and params[:page].blank?
      redirect_to @domains.first
    else
      if params[:name]
        if params[:name] == ''
          @title = 'All domains'
        else
          @title = "Search '#{params[:name]}' "
        end
      else
        @title = params[:framework] || params[:feature] || params[:engine] || params[:server] || params[:doctype] || params[:ip] || params[:city] || params[:country]
        @title = @title.titleize
      end
    end
  end

  def whois
    @domain = Domain.find_by_name(decode_domain_name(params[:id]))
    @title = "Whois #{@domain.name}"

    begin
      client = Whois::Client.new

      @whois = client.query(@domain.name).to_s
    rescue StandardError => err
      logger.error "#{@domain.name}: #{err}"
    end
  rescue ActiveRecord::RecordNotFound
    render :action => "410", :status => '410 Gone'
  end

  def pagerank
    @domain = Domain.find_by_name(decode_domain_name(params[:id]))
    @title = "Pagerank #{@domain.name}"

    @pagerank = PageRankr.ranks(@domain.name, :alexa_us, :alexa_global, :compete, :google)
  rescue ActiveRecord::RecordNotFound
    render :action => "410", :status => '410 Gone'
  end

  def analyze
    name = decode_domain_name(params[:id])
    domain = Domain.find_by_name(name)
    unless domain
      if domain_name_valid?(decode_domain_name(name))
        domain = Domain.create_from_list('custom', name)
      else
        raise 'Invalid domain name'
      end
    end

    if domain.analyzed_at and domain.analyzed_at > 1.hour.ago
      redirect_to domain
    else
      @title = "Analyzing #{domain.name}"
      @task = true

      Resque.enqueue(Analyzers::AnalyzeDomain, domain.id) unless request.referer == request.url # refreshed
    end
  rescue ActiveRecord::RecordNotFound
    render :action => "410", :status => '410 Gone'
  end

  def countries
    @title = 'All countries'
    @countries = Domain.group(:tld).order('count(*) desc').where('tld is not null').having('count(*) > 1000').map(&:tld)
  end

  private

  def set_params_tld
    params[:tld] = 'Global' unless params[:tld] =~ /^\w+$/

    if COUNTRIES[params[:tld]]
      @tld = COUNTRIES[params[:tld]]
    else
      @tld = params[:tld]
    end
    @tld_set = "(#{Array.wrap(@tld).map{|t| "'#{t}'" }.join(',')})"
  end

  def set_markers
    @markers = []
  end

  def distribution(data, attribute, threshold = 0)
    other = 0
    dist = data.select do |row|
      row[0] = "Undetected" if row[0] == nil
      other += row[1] if row[1] <= threshold
      row[1] > threshold
    end
    dist = dist.map do |data|
        if data[0] == 'Undetected'
          data
        else
          ["<a href=\"#{url_for search_domains_path(attribute => data[0], :tld => params[:tld])}\">#{data[0]}</a>", data[1]]
        end
      end
    dist << ["Other", other] if other > 0
    dist
  end
end
