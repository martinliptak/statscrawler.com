class ListsController < ApplicationController
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::AssetTagHelper

  def show
    @domains = Domain.includes(:list_domains).where('list_domains.list' => params[:id])

    @list = params[:id] if ['sk_nic', 'cz', 'dmoz'].include? params[:id]

    @distribution = {}

    @distribution[:framework] = distribution(Domain.connection.execute("
      select framework, count(*) from pages
        join domains on page_id = pages.id
        join list_domains on domain_id = domains.id and list = '#{@list}'
        where framework is not null
        group by framework order by count(*) desc"), :framework)

    @distribution[:feature] = distribution(Domain.connection.execute("
      select features.name, count(*) from features
        join pages on features.page_id = pages.id
        join domains on domains.page_id = pages.id
        join list_domains on domain_id = domains.id and list = '#{@list}'
        group by name order by count(*) desc"), :feature)

    for type in [:server, :engine, :doctype]
      @distribution[type] = distribution(Domain.connection.execute("
        select #{type}, count(*) from pages
          join domains on page_id = pages.id
          join list_domains on domain_id = domains.id and list = '#{@list}'
          group by #{type} order by count(*) desc"), type, @domains.count / 100)
    end

    @html5 = Domain.connection.execute("
      select count(*) from pages
        join domains on page_id = pages.id
        join list_domains on domain_id = domains.id and list = '#{@list}'
        where doctype = 'html' ").first.first

    @distribution[:country] = distribution(Domain.connection.execute("
      select country, count(*) from locations
        join domains on locations.id = domains.location_id
        join list_domains on domain_id = domains.id and list = '#{@list}'
        group by country order by count(*) desc"), :country, @domains.count / 100)

    @distribution[:city] = distribution(Domain.connection.execute("
      select city, count(*) from locations
        join domains on locations.id = domains.location_id
        join list_domains on domain_id = domains.id and list = '#{@list}'
        where city <> ' '
        group by city order by count(*) desc limit 10"), :city)

    @markers = Domain.connection.execute("
      select longitude, latitude, count(*), city from locations
        join domains on locations.id = domains.location_id
        join list_domains on domain_id = domains.id and list = '#{@list}'
        where longitude is not null and latitude is not null and city <> ' '
        group by longitude, latitude").map { |marker|
      {
        :latitude => marker[1],
        :longitude => marker[0],
        :title => marker[3],
        :icon => marker_icon(marker[2]),
        :zoom => marker[2] < 80 ? 8 : 0,
        :html => "<b>#{marker[3]}</b><br/>
                    <a href=#{url_for(search_domains_path(:city => marker[3],:list => @list))}>#{pluralize(marker[2], 'domain')}</a>"
      }
    }
  end

  private

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
          ["<a href=\"#{url_for search_domains_path(attribute => data[0], :list => @list)}\">#{data[0]}</a>", data[1]]
        end
      end
    dist << ["Other", other]
    dist
  end


  def marker_icon(domains)
    case domains
       when 0..30
          {
              :image => "/images/0.png",
              :iconsize => [18, 23],
              :iconanchor => [9, 23],
              :infowindowanchor => [9, 0]
          }
       when 30..1000
          {
              :image => "/images/1.png",
              :iconsize => [27, 34],
              :iconanchor => [13, 34],
              :infowindowanchor => [13, 0]
          }
       when 1000..10000
          {
              :image => "/images/2.png",
              :iconsize => [33, 42],
              :iconanchor => [16, 33],
              :infowindowanchor => [16, 0]
          }
       when 10000..1000000
          {
              :image => "/images/3.png",
              :iconsize => [40, 51],
              :iconanchor => [20, 51],
              :infowindowanchor => [20, 0]
          }
     end
  end
end
