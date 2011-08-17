require 'spec_helper'

describe ListDomain do

  it "should create domain from list" do
    Domain.create_from_list("list", "first")
    Domain.count.should == 1
    ListDomain.count.should == 1
    
    first = Domain.first
    first.name.should == 'first'
    first.page.should be_blank
    first.location.should be_blank
    first.analyzed_at.should be_blank
    
    Domain.create_from_list("list", "second")
    Domain.count.should == 2
    ListDomain.count.should == 2
    
    Domain.create_from_list("list2", "second")
    Domain.count.should == 2
    ListDomain.count.should == 3
  end
  
  it "should provide analyze helper method" do
    first = Domain.create_from_list("list", "first").domain
    
    Timecop.freeze(Time.now) {
      first.analyze { |domain|
        domain.name = 'second'
      }  
      
      first = Domain.find(first.id)
      first.name.should == 'second'
      first.page.should be_blank
      first.location.should be_blank
      first.analyzed_at.should == Time.now.to_s
    }
  end
  
  it "should enqueue analyze job when created" do
    first = Domain.create_from_list("list", "first").domain
    
    job = Resque.reserve(:high)
    job.payload_class.should == Analyzers::Performer
    job.args.first.should == first.id  
  end
end
