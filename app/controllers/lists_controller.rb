class ListsController < ApplicationController
  LISTS = ['sk_nic', 'cz', 'dmoz']

  def show
    if params[:id] and LISTS.include?(params[:id])
      @list = params[:id]
    else
      @list = 'dmoz'
    end
    @domains = Domain.includes(:list_domains).where('list_domains.list' => @list).analyzed

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

    @distribution[:ipv6] = Domain.connection.execute("
      select if(ipv6, 'Yes', 'No'), count(*) from domains
        join list_domains on domain_id = domains.id and list = '#{@list}'
        where ipv6 is not null
        group by ipv6 order by count(*) desc")

    @distribution[:country] = distribution(Domain.connection.execute("
      select country, count(*) from locations
        join domains on locations.id = domains.location_id
        join list_domains on domain_id = domains.id and list = '#{@list}'
        group by country order by count(*) desc"), :country, @domains.count / 150)

    @distribution[:city] = distribution(Domain.connection.execute("
      select city, count(*) from locations
        join domains on locations.id = domains.location_id
        join list_domains on domain_id = domains.id and list = '#{@list}'
        where city <> ' '
        group by city order by count(*) desc limit 12"), :city)

    @markers = Domain.connection.execute("
      select longitude, latitude, count(*), city from locations
        join domains on locations.id = domains.location_id
        join list_domains on domain_id = domains.id and list = '#{@list}'
        where longitude is not null and latitude is not null and city <> ' '
        group by longitude, latitude order by count(*) desc limit 1000").map { |marker|
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
    dist << ["Other", other] if other > 0
    dist
  end
end
