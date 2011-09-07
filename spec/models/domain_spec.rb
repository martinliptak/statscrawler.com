require 'spec_helper'

describe Domain do

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

  it "should destroy associated page when no domains exist" do
    page = Page.create :url => 'page'
    first = Domain.create :name => 'first', :page => page
    second = Domain.create :name => 'second', :page => page

    Domain.count.should == 2
    Page.count.should == 1

    first.destroy
    Domain.count.should == 1
    Page.count.should == 1

    second.destroy
    Domain.count.should == 0
    Page.count.should == 0
  end

  it "should destroy associated location when no domains exist" do
    location = Location.create :ip => 'location'
    first = Domain.create :name => 'first', :location => location
    second = Domain.create :name => 'second', :location => location

    Domain.count.should == 2
    Location.count.should == 1

    first.destroy
    Domain.count.should == 1
    Location.count.should == 1

    second.destroy
    Domain.count.should == 0
    Location.count.should == 0
  end

  it "should return domain url" do
    Domain.create(:name => 'statistiky-domen.sk')
    Domain.last.reload.url.should == 'http://www.statistiky-domen.sk'

    Domain.create(:name => 'www.statistiky-domen.sk')
    Domain.last.reload.url.should == 'http://www.statistiky-domen.sk'

    Domain.create(:name => 'rails.statistiky-domen.sk')
    Domain.last.reload.url.should == 'http://rails.statistiky-domen.sk'

    Domain.create(:name => 'statistiky-domen.co.uk')
    Domain.last.reload.url.should == 'http://statistiky-domen.co.uk'
  end
end
