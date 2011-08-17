require 'spec_helper'

describe ListDomain do

  it "should create domain from list" do
    Domain.create_from_list("list", "first")
    Domain.count.should == 1
    ListDomain.count.should == 1
    
    Domain.create_from_list("list", "second")
    Domain.count.should == 2
    ListDomain.count.should == 2
    
    Domain.create_from_list("list2", "second")
    Domain.count.should == 2
    ListDomain.count.should == 3
  end
end
