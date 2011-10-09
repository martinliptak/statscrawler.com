require 'spec_helper'

describe Parsers::DmozParser do

  it "should parse DMOZ dump" do
    gz = File.read(File.dirname(__FILE__) + '/../fixtures/content.rdf.u8.gz')
    FakeWeb.register_uri(:get, 'http://rdf.dmoz.org/rdf/content.rdf.u8.gz', :body => gz)

    Parsers::DmozParser.perform

    Domain.count.should == 143

    first = Domain.first
    first.name.should == 'www.w3.org'
    first.page_id.should be_nil
    first.location_id.should be_nil
    first.analyzed_at.should be_nil
  end
end
