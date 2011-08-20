require 'spec_helper'

describe Analyzers::MassPerformer do

  it "should download and analyze domain" do
    FakeWeb.register_uri(:get, "http://www.statistiky-domen.sk", :body => '<html></html>')
    
    domain = Domain.create(:name => 'statistiky-domen.sk')

    Timecop.freeze(Time.now) {
      Analyzers::MassPerformer.perform

      Domain.count.should == 1
      Page.count.should == 1
      Source.count.should == 1

      domain = Domain.find(domain.id)
      domain.page.should == Page.last
      domain.page.source.should == Source.last
      domain.page.source.headers.should_not be_nil
      domain.page.source.body.should == '<html></html>'
      domain.analyzed_at.should == Time.now.to_s
    }
  end
end
