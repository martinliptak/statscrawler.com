require 'spec_helper'

describe ListDomain do

  it "should destroy associated domain when no other lists exist" do
    domain = Domain.create :name => 'domain'
    first = domain.list_domains.create :list => 'first'
    second = domain.list_domains.create :list => 'second'
    
    Domain.count.should == 1
    ListDomain.count.should == 2
    
    first.destroy
    Domain.count.should == 1
    ListDomain.count.should == 1
    
    second.destroy
    Domain.count.should == 0
    ListDomain.count.should == 0
  end
end
