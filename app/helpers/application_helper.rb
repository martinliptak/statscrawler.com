module ApplicationHelper

  def title
    @title ? "#{@title} | Statscrawler.com" : "Statscrawler.com"
  end

  def menu_item(title, path)
    "<li class=\"right #{current_page?(path) ? "active" : ""}\">#{link_to title, path}</li>".html_safe
  end
end
