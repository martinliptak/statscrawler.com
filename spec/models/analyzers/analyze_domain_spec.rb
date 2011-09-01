require 'spec_helper'

describe Analyzers::AnalyzeDomain do

  describe 'Job' do
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

    it "should not create duplicate pages" do
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
        Analyzers::AnalyzeDomain.perform(Domain.last)

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
        Analyzers::AnalyzeDomain.perform(Domain.last)
      }

      Timecop.freeze(Time.now) {
        Analyzers::AnalyzeDomain.perform(Domain.last)

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

  describe "Daemon" do
    it "should download and analyze domain" do
      FakeWeb.register_uri(:get, "http://www.statistiky-domen.sk",
                           :body => '<html><head><script src="jquery.js"></script><script src="prototype.js"></script></head></html>',
                           :server => :nginx)
      FakeWeb.register_uri(:get, "http://www.statistiky-domen-second.sk",
                           :body => '<html><head><script src="jquery.js"></script></head>second</html>',
                           :server => :apache)

      Domain.create(:name => 'statistiky-domen.sk')
      Domain.create(:name => 'statistiky-domen-second.sk')

      Timecop.freeze(Time.now) {
        Analyzers::AnalyzeDomain.daemon(0)

        Domain.count.should == 2
        Page.count.should == 2
        Source.count.should == 2
        Feature.count.should == 3

        domain = Domain.first
        domain.page.should == Page.first
        domain.page.source.should == Source.first
        domain.page.source.headers.should_not be_nil
        domain.page.source.body.should == '<html><head><script src="jquery.js"></script><script src="prototype.js"></script></head></html>'
        domain.page.server.should == 'nginx'
        domain.page.features.count.should == 2
        domain.analyzed_at.should == Time.now.to_s

        domain = Domain.last
        domain.page.should == Page.last
        domain.page.source.should == Source.last
        domain.page.source.headers.should_not be_nil
        domain.page.source.body.should == '<html><head><script src="jquery.js"></script></head>second</html>'
        domain.page.server.should == 'apache'
        domain.page.features.count.should == 1
        domain.analyzed_at.should == Time.now.to_s
      }
    end

    it "should not create duplicate pages" do
      FakeWeb.register_uri(:get, "http://www.statistiky-domen.sk",
                           :body => '<html><head><script src="jquery.js"></script><script src="prototype.js"></script></head></html>',
                           :server => :nginx)
      FakeWeb.register_uri(:get, "http://www.statistiky-domen-redirect.sk",
                           :status => ["301", "Moved Permanently"], :location => "http://www.statistiky-domen.sk")

      Domain.create(:name => 'statistiky-domen.sk')
      Timecop.freeze(Time.now) {
        Analyzers::AnalyzeDomain.daemon(0)

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
        Analyzers::AnalyzeDomain.daemon(0)

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
        Analyzers::AnalyzeDomain.daemon(0)
      }

      Timecop.freeze(Time.now) {
        Domain.first.update_attributes(:analyzed_at => nil)
        Domain.first.page.source.delete
        Analyzers::AnalyzeDomain.daemon(0)

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
end
