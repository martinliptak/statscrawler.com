require 'spec_helper'

describe Analyzers::Performer do

  it "should download and analyze domain" do
    FakeWeb.register_uri(:get, "http://www.statistiky-domen.sk",
                         :body => '<html><head><script src="jquery.js"></script><script src="prototype.js"></script></head></html>',
                         :server => :nginx)
    
    Domain.create(:name => 'statistiky-domen.sk')
    
    Timecop.freeze(Time.now) {
      Analyzers::Performer.perform(Domain.first)
      
      Domain.count.should == 1
      Page.count.should == 1
      Source.count.should == 1
      Feature.count.should == 2

      domain = Domain.first
      domain.page.should == Page.first
      domain.page.source.should == Source.first
      domain.page.source.headers.should_not be_nil
      domain.page.source.body.should == '<html><head><script src="jquery.js"></script><script src="prototype.js"></script></head></html>'
      domain.page.server.should == 'nginx'
      domain.page.features.count.should == 2
      domain.analyzed_at.should == Time.now.to_s
    } 
  end

  it "it should not create duplicate pages" do
    FakeWeb.register_uri(:get, "http://www.statistiky-domen.sk",
                         :body => '<html><head><script src="jquery.js"></script><script src="prototype.js"></script></head></html>',
                         :server => :nginx)
    FakeWeb.register_uri(:get, "http://www.statistiky-domen-redirect.sk",
                         :status => ["301", "Moved Permanently"], :location => "http://www.statistiky-domen.sk")

    Domain.create(:name => 'statistiky-domen.sk')
    Timecop.freeze(Time.now) {
      Analyzers::Performer.perform(Domain.last)

      Domain.count.should == 1
      Page.count.should == 1
      Source.count.should == 1
      Feature.count.should == 2

      domain = Domain.last
      domain.page.should == Page.last
      domain.page.source.should == Source.last
      domain.page.source.headers.should_not be_nil
      domain.page.source.body.should == '<html><head><script src="jquery.js"></script><script src="prototype.js"></script></head></html>'
      domain.page.server.should == 'nginx'
      domain.page.features.count.should == 2
      domain.analyzed_at.should == Time.now.to_s
    }

    Domain.create(:name => 'statistiky-domen-redirect.sk')
    Timecop.freeze(Time.now) {
      Analyzers::Performer.perform(Domain.last)

      Domain.count.should == 2
      Page.count.should == 1
      Source.count.should == 1

      domain = Domain.last.reload
      domain.page.should == Page.last
      domain.page.source.should == Source.last
      domain.page.source.headers.should_not be_nil
      domain.page.source.body.should == '<html><head><script src="jquery.js"></script><script src="prototype.js"></script></head></html>'
      domain.page.server.should == 'nginx'
      domain.analyzed_at.should == Time.now.to_s
    }
  end

  it "should re-download and re-analyze domain" do
    FakeWeb.register_uri(:get, "http://www.statistiky-domen.sk",
                         :body => '<html><head><script src="jquery.js"></script><script src="prototype.js"></script></head></html>',
                         :server => :nginx)

    Domain.create(:name => 'statistiky-domen.sk')

    Timecop.freeze(Time.now) {
      Analyzers::Performer.perform(Domain.last)
    }

    Timecop.freeze(Time.now) {
      Analyzers::Performer.perform(Domain.last)

      Domain.count.should == 1
      Page.count.should == 1
      Source.count.should == 1
      Feature.count.should == 2

      domain = Domain.first
      domain.page.should == Page.first
      domain.page.source.should == Source.first
      domain.page.source.headers.should_not be_nil
      domain.page.source.body.should == '<html><head><script src="jquery.js"></script><script src="prototype.js"></script></head></html>'
      domain.page.server.should == 'nginx'
      domain.analyzed_at.should == Time.now.to_s
    }
  end
end
