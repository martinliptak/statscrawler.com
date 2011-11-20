require 'spec_helper'

require 'resolv'
Resolv::DNS.class_eval do
  def getaddress(name)
    case name
      when 'statistiky-domen.sk', 'statistiky-domen-redirect.sk'
        '195.210.28.80'
      when 'statistiky-domen-second.sk'
        '195.210.28.81'
    end
  end
  
  def getresources(name, typename)
  end
end

describe Analyzers::AnalyzeDomain do

    it "should download and analyze domain" do
      FakeWeb.register_uri(:get, "http://www.statistiky-domen.sk",
                           :body => '<html><head><script src="jquery.js"></script><script src="prototype.js"></script></head></html>',
                           :server => :nginx)

      Domain.create(:name => 'statistiky-domen.sk')

      Timecop.freeze(Time.now) {
        Analyzers::AnalyzeDomain.perform(Domain.first)

        Domain.count.should == 1
        Page.count.should == 1
        Source.count.should == 1
        Feature.count.should == 2
        Location.count.should == 1

        domain = Domain.first
        domain.page.should == Page.first
        domain.page.source.should == Source.first
        domain.page.source.headers.should_not be_nil
        domain.page.source.body.should == '<html><head><script src="jquery.js"></script><script src="prototype.js"></script></head></html>'
        domain.page.server.should == 'nginx'
        domain.page.features.count.should == 2
        domain.location.should == Location.first
        domain.location.ip.should == '195.210.28.80'
        domain.location.country.should == 'Slovakia'
        domain.location.city.should be_kind_of String
        domain.location.longitude.should be_kind_of Numeric
        domain.location.latitude.should be_kind_of Numeric
        domain.analyzed_at.should == Time.now.to_s
      }
    end

    it "should not create duplicate pages and locations" do
      FakeWeb.register_uri(:get, "http://www.statistiky-domen.sk",
                           :body => '<html><head><script src="jquery.js"></script><script src="prototype.js"></script></head></html>',
                           :server => :nginx)
      FakeWeb.register_uri(:get, "http://www.statistiky-domen-redirect.sk",
                           :status => ["301", "Moved Permanently"], :location => "http://www.statistiky-domen.sk")

      Domain.create(:name => 'statistiky-domen.sk')
      Timecop.freeze(Time.now) {
        Analyzers::AnalyzeDomain.perform(Domain.last)

        Domain.count.should == 1
        Page.count.should == 1
        Source.count.should == 1
        Feature.count.should == 2
        Location.count.should == 1

        domain = Domain.last
        domain.page.should == Page.last
        domain.page.source.should == Source.last
        domain.page.source.headers.should_not be_nil
        domain.page.source.body.should == '<html><head><script src="jquery.js"></script><script src="prototype.js"></script></head></html>'
        domain.page.server.should == 'nginx'
        domain.page.features.count.should == 2
        domain.location.should == Location.first
        domain.location.ip.should == '195.210.28.80'
        domain.location.country.should == 'Slovakia'
        domain.location.city.should be_kind_of String
        domain.location.longitude.should be_kind_of Numeric
        domain.location.latitude.should be_kind_of Numeric
        domain.analyzed_at.should == Time.now.to_s
      }

      Domain.create(:name => 'statistiky-domen-redirect.sk')
      Timecop.freeze(Time.now) {
        Analyzers::AnalyzeDomain.perform(Domain.last)

        Domain.count.should == 2
        Page.count.should == 1
        Source.count.should == 1
        Location.count.should == 1

        domain = Domain.last.reload
        domain.page.should == Page.last
        domain.page.source.should == Source.last
        domain.page.source.headers.should_not be_nil
        domain.page.source.body.should == '<html><head><script src="jquery.js"></script><script src="prototype.js"></script></head></html>'
        domain.page.server.should == 'nginx'
        domain.location.should == Location.first
        domain.location.ip.should == '195.210.28.80'
        domain.location.country.should == 'Slovakia'
        domain.location.city.should be_kind_of String
        domain.location.longitude.should be_kind_of Numeric
        domain.location.latitude.should be_kind_of Numeric
        domain.analyzed_at.should == Time.now.to_s
      }
    end

    it "should re-download and re-analyze domain" do
      FakeWeb.register_uri(:get, "http://www.statistiky-domen.sk",
                           :body => '<html><head><script src="jquery.js"></script><script src="prototype.js"></script></head></html>',
                           :server => :nginx)

      Domain.create(:name => 'statistiky-domen.sk')

      Timecop.freeze(Time.now) {
        Analyzers::AnalyzeDomain.perform(Domain.last)
      }

      Timecop.freeze(Time.now) {
        Analyzers::AnalyzeDomain.perform(Domain.last)

        Domain.count.should == 1
        Page.count.should == 1
        Source.count.should == 1
        Feature.count.should == 2
        Location.count.should == 1

        domain = Domain.first
        domain.page.should == Page.first
        domain.page.source.should == Source.first
        domain.page.source.headers.should_not be_nil
        domain.page.source.body.should == '<html><head><script src="jquery.js"></script><script src="prototype.js"></script></head></html>'
        domain.page.server.should == 'nginx'
        domain.location.should == Location.first
        domain.location.ip.should == '195.210.28.80'
        domain.location.country.should == 'Slovakia'
        domain.location.city.should be_kind_of String
        domain.location.longitude.should be_kind_of Numeric
        domain.location.latitude.should be_kind_of Numeric
        domain.analyzed_at.should == Time.now.to_s
      }
    end
end
