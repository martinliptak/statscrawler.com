require "whois"
require "page_rankr"

class DomainsController < ApplicationController
  include DomainsHelper

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

    unless params[:list].blank?
      tables << :list_domains
      where['list_domains.list'] = params[:list]

      @list = params[:list]
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

end
