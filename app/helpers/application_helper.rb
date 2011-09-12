module ApplicationHelper

  def title
    @title ? "#{@title} | Statscrawler.com" : "Statscrawler.com"
  end

  def list(title, list)
    "<li class=\"right #{list == @list ? "active" : ""}\">#{link_to title, list_path(list)}</li>".html_safe
  end
end
