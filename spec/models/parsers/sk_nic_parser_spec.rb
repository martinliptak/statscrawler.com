require 'spec_helper'

describe Parsers::SkNicParser do

  it "should download and parse SK-NIC domain list" do
    gz = File.read(File.dirname(__FILE__) + '/../fixtures/sknic_1.txt.gz')
    FakeWeb.register_uri(:get, "https://www.sk-nic.sk/documents/domeny_1.txt.gz", :body => gz)
    Parsers::SkNicParser.perform
    
    Domain.count.should == 62
    
    first = Domain.first
    first.name.should == '0-0.sk'
    first.tld.should == 'sk'
    first.page_id.should be_nil 
    first.location_id.should be_nil 
    first.analyzed_at.should be_nil
  end
  
  it "should destroy domains removed from list" do
    gz = File.read(File.dirname(__FILE__) + '/../fixtures/sknic_1.txt.gz')
    FakeWeb.register_uri(:get, "https://www.sk-nic.sk/documents/domeny_1.txt.gz", :body => gz)
    Parsers::SkNicParser.perform 
    Domain.count.should == 62
    last = Domain.last
    
    gz = File.read(File.dirname(__FILE__) + '/../fixtures/sknic_2.txt.gz')
    FakeWeb.register_uri(:get, "https://www.sk-nic.sk/documents/domeny_1.txt.gz", :body => gz)
    Parsers::SkNicParser.perform
    
    Domain.count.should == 55
    
    first = Domain.first
    first.name.should == '001.sk'
    first.page_id.should be_nil 
    first.location_id.should be_nil 
    first.analyzed_at.should be_nil
    
    Domain.find_by_name(last.name).should == last
  end
  
  it "should create domains added to list" do
    gz = File.read(File.dirname(__FILE__) + '/../fixtures/sknic_2.txt.gz')
    FakeWeb.register_uri(:get, "https://www.sk-nic.sk/documents/domeny_1.txt.gz", :body => gz)
    Parsers::SkNicParser.perform
    Domain.count.should == 55
    last = Domain.last
  
    gz = File.read(File.dirname(__FILE__) + '/../fixtures/sknic_3.txt.gz')
    FakeWeb.register_uri(:get, "https://www.sk-nic.sk/documents/domeny_1.txt.gz", :body => gz)
    Parsers::SkNicParser.perform
    
    Domain.count.should == 64
    first = Domain.first
    
    Domain.find_by_name(last.name).should == last
  end
end
