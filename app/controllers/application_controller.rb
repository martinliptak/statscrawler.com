class ApplicationController < ActionController::Base
  protect_from_forgery

  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::AssetTagHelper

  protected

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
