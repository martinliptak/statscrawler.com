class DomainsController < ApplicationController
  def show

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
        @title = "Search '#{params[:name]}' "
      else
        @title = params[:framework] || params[:feature] || params[:engine] || params[:server] || params[:doctype] || params[:ip] || params[:city] || params[:country]
        @title = @title.titleize
      end
    end
  end

end
