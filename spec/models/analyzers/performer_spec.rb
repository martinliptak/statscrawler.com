require 'spec_helper'

describe Analyzers::Performer do

  it "should download and analyze domain" do
    FakeWeb.register_uri(:get, "http://www.statistiky-domen.sk", :body => '<html></html>')
    Parsers::SkNicParser.perform
    
    domain = Domain.create(:name => 'statistiky-domen.sk')
    
    Timecop.freeze(Time.now) {
      Analyzers::Performer.perform(domain.id)
      
      domain = Domain.find(domain.id)
      domain.page.should_not be_nil
      domain.page.source.headers.should_not be_nil
      domain.page.source.body.should == '<html></html>'
      domain.analyzed_at.should == Time.now.to_s
    } 
  end
end
