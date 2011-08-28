module Analyzers
  class Analyzer < BaseAnalyzer
    def run
      super do
        resources = []

        # server
        header "server" do |serv|
          case serv
            when /^apache/i
              server :apache
            when /^nginx/i
              server :nginx
            when /^microsoft-iis/i
              server :microsoft_iis
            when /^lighttpd/i
              server :lighttpd
            when /^mongrel/i
              engine :ruby
              server :mongrel
            else
              server serv
          end
        end

        # engine
        header "x-powered-by" do |x_powered_by|
          case x_powered_by
            when /^php/i
              engine :php
            when /^asp/i
              engine :asp
            when /^nette/i
              framework :nette
              engine :php
            when /^w3 total cache/i
              framework :wordpress
              engine :php
            when /^(servlet|jsp|jsf)/i
              engine :java
            when /^phusion passenger/i
              engine :ruby
              framework :rails
            when "Chuck Norris!"
              engine_final x_powered_by # chuck norris is final
            else
              engine x_powered_by
          end
        end

        # cookies
        header "set-cookie" do |set_cookie|
          case set_cookie
            when /^PHPSESSID/
              engine :php
            when /^ASP\.NET/
              engine :asp
            when /^JSESSIONID/
              engine :java
            when /^CAKEPHP/
              framework :cakephp
            when /^symfony/
              framework :symfony
            when /^zenid/
              framework :zencart
          end
        end

        # doctype
        regexp /^\s*(<\?xml[^?]+\?>)?\s*<!doctype\s*(html\s*public\s*".[^"]*"|html)/i do |match|
          doctype match[2].delete("\n\r").strip.squeeze(" ").downcase
        end

        # powered by opencart
        regexp /<!--[^>]*Powered By OpenCart/ do
          framework :opencart
        end

        # google adsense
        regexp /<!--\s*google_ad_section_start/ do
          feature :google_adsense
        end

        # scripts
        element("script") do |script|
          attribute(script, "src") do |src|
            # full path
            case src
              when "/media/system/js/mootools.js"
                framework :joomla
              when "http://www.google-analytics.com/ga.js"
                feature :google_analytics
              when %r{^(http://static\.ak\.fbcdn\.net|http://connect\.facebook\.net)}
                feature :facebook
              when %r{^http://\w{2,3}.search.etargetnet.com}
                feature :etarget
              when "http://pagead2.googlesyndication.com/pagead/show_ads.js"
                feature :google_adsense
            end

            # filename
            filename(src) do |filename|
              case filename
                when /^jquery/i
                  feature :jquery
                when /^jquery-ui/i
                  feature :jquery_ui
                when /^prototype/i
                  feature :prototype
                when /^scriptaculous/i
                  feature :scriptaculous
                when /^mootools/i
                  feature :mootools
                when /^drupal/i
                  framework :drupal
              end
            end

            resources << src
          end

          # script text content
          case script
            when /^.{0,30}jQuery\.extend\(Drupal\.settings/
              framework :drupal
            when /jQuery/
              feature :jquery
            when /['"]UA-[\d-]{5,}["']/
              feature :google_analytics
            when %r{//connect\.facebook\.net}
              feature :facebook
            when %r{var\s*EtargetBannerIdent|http://\w{2,3}.search.etargetnet.com}
              feature :etarget
          end
        end

        # stylesheets
        element("link[rel=stylesheet]") do |style|
          attribute(style, "href") do |href|
            # full path
            case href
              when /modules\/node\/node\.css/
                framework :drupal
              when %r{/themes/[^/]+/css/global\.css}
                framework :prestashop
              when %r{^catalog/view/theme/[^/]+/stylesheet/stylesheet.css}
                framework :opencart
            end

            # filename
            filename(href) do |filename|
              case filename
                when /^uc_product/i
                  framework_final :ubercart
              end
            end

            resources << href
          end
        end

         # inline styles
        element("style") do |style|
          case style
            when /^@import "(\/modules\/node\/node\.css|\/misc\/drupal\.css)";/
              framework :drupal
           end
        end

        # images
        element("img") do |img|
          attribute(img, 'src') do |src|
            resources << src
          end
        end

        # iframe
        element("iframe") do |iframe|
          attribute(iframe, "src") do |src|
            case src
              when /^http:\/\/www.facebook.com/
                feature :facebook
            end
          end
        end

        # image, stylesheet, script paths
        resources.each do |link|
          case link
            when /^\/sites\/[\w\d\-.]+\/(files|themes|modules)/
              framework :drupal
            when /\/(wp-includes\/js|wp-content\/(plugins|themes))\//
              framework :wordpress
            when /com_virtuemart/
              framework_final :virtuemart
            when %r{^/(javascripts|stylesheets|images)/([^/]+/)*[^/]*\.\w{2,4}\?\d{10}$|^/assets/([^/+])*/[^/]*-[a-f0-9]{32}}
              framework :rails
          end
        end

        # meta name=generator
        generator do |content|
          case content
            when /^joomla/i
              framework :joomla
            when /^typo3/i
              framework :typo3
            when /^wordpress/i
              framework :wordpress
            when /^drupal/i
              framework :drupal
            when /^shopping cart program by Zen Cart/
              framework :zencart
            when /^prestashop/i
              framework :prestashop
          end
        end

        # rails authenticity token
        element("form input[name=authenticity_token], meta[name=csrf-param], meta[name=csrf-token]") do
          framework :rails
        end

        # ubercart classes
        element(".uc-price, .uc-price-product, .block-uc_cart") do
          framework_final :ubercart
        end

        # framework implies engine
        engine :php if framework_in? [:joomla, :wordpress, :drupal, :typo3, :virtuemart, :nette, :ubercart,
                                      :cakephp, :symfony, :zencart, :prestashop, :opencart]
        engine :ruby if framework_in? [:rails]
      end
    end
  end
end