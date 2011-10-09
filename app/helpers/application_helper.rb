module ApplicationHelper

  def title
    @title ? "#{@title} | Statscrawler.com" : "Statscrawler.com"
  end

  def item(title, tld)
    "<li class=\"right #{params[:tld] == tld ? "active" : ""}\">#{link_to title, root_path(:tld => tld)}</li>".html_safe
  end
end
