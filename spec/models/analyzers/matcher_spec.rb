require 'spec_helper'

describe Analyzers::Matcher do

  it "should detect facebook 1" do
    result = run_matcher_on_fixture(1)
    result[:description].should == "0101.sk domena plna zabavy, vtipy, humor, zabava, online hry a omnoho viac"
    result[:keywords].should == "nesmrtelnost,extra vtipy,vtip baza,humorne situacie,morbidne obrazky,domena plna zabavy"
    result[:server].should == :nginx
    result[:engine].should == :php
    result[:doctype].should == "html public \"-//w3c//dtd xhtml 1.0 strict//en\""
    result[:features].should include :jquery
    result[:features].should include :facebook
    result[:features].should include :google_adsense
    result[:features].should include :google_analytics
    result[:features].size.should == 4
  end

  it "should detect facebook 2" do
    result = run_matcher_on_fixture(2)
    result[:server].should == :nginx
    result[:engine].should == :php
    result[:doctype].should == "html public \"-//w3c//dtd xhtml 1.0 strict//en\""
    result[:features].should include :mootools
    result[:features].should include :facebook
    result[:features].should include :google_analytics
    result[:features].size.should == 3
  end

  it "should detect facebook 3" do
    result = run_matcher_on_fixture(3)
    result[:server].should == :nginx
    result[:engine].should == :php
    result[:doctype].should == "html public \"-//w3c//dtd xhtml 1.0 transitional//en\""
    result[:framework].should == :wordpress
    result[:features].should include :jquery
    result[:features].should include :facebook
    result[:features].size.should == 2
  end

  it "should detect drupal 1" do
    result = run_matcher_on_fixture(4)
    result[:server].should == :apache
    result[:framework].should == :drupal
    result[:engine].should == :php
    result[:doctype].should == "html public \"-//w3c//dtd xhtml 1.0 strict//en\""
    result[:features].should include :jquery
    result[:features].size.should == 1
  end

  it "should detect drupal 2" do
    result = run_matcher_on_fixture(5)
    result[:server].should == :apache
    result[:framework].should == :drupal
    result[:engine].should == :php
    result[:doctype].should == "html public \"-//w3c//dtd xhtml 1.0 strict//en\""
    result[:features].should include :jquery
    result[:features].size.should == 1
  end

  it "should detect drupal 3" do
    result = run_matcher_on_fixture(6)
    result[:server].should == :apache
    result[:framework].should == :drupal
    result[:engine].should == :php
    result[:doctype].should == "html public \"-//w3c//dtd xhtml 1.0 strict//en\""
  end

  it "should detect drupal 4" do
    result = run_matcher_on_fixture(7)
    result[:framework].should == :drupal
    result[:engine].should == :php
    result[:doctype].should == "html public \"-//w3c//dtd xhtml 1.0 strict//en\""
    result[:features].should include :jquery
    result[:features].should include :google_analytics
    result[:features].size.should == 2
  end

  it "should detect drupal 5" do
    result = run_matcher_on_fixture(8)
    result[:framework].should == :drupal
    result[:engine].should == :php
    result[:doctype].should == "html public \"-//w3c//dtd xhtml 1.0 strict//en\""
    result[:features].should include :jquery
    result[:features].should include :google_analytics
    result[:features].size.should == 2
  end

  it "should detect drupal 6" do
    result = run_matcher_on_fixture(9)
    result[:framework].should == :drupal
    result[:doctype].should == "html public \"-//w3c//dtd xhtml+rdfa 1.0//en\""
    result[:features].should include :jquery
    result[:features].size.should == 1
  end

  it "should detect drupal 7" do
    result = run_matcher_on_fixture(10)
    result[:framework].should == :drupal
    result[:doctype].should == "html public \"-//w3c//dtd xhtml 1.0 strict//en\""
  end

  it "should detect prestashop 1" do
    result = run_matcher_on_fixture(11)
    result[:framework].should == :prestashop
    result[:doctype].should == "html public \"-//w3c//dtd xhtml 1.1//en\""
  end

  it "should detect prestashop 2" do
    result = run_matcher_on_fixture(12)
    result[:framework].should == :prestashop
    result[:doctype].should == "html public \"-//w3c//dtd xhtml 1.1//en\""
  end

  it "should detect opencart 1" do
    result = run_matcher_on_fixture(13)
    result[:framework].should == :opencart
    result[:doctype].should == "html public \"-//w3c//dtd xhtml 1.0 strict//en\""
  end

  it "should detect opencart 2" do
    result = run_matcher_on_fixture(14)
    result[:framework].should == :opencart
    result[:doctype].should == "html public \"-//w3c//dtd xhtml 1.0 strict//en\""
  end

  it "should detect rails 3.1" do
    result = run_matcher_on_fixture(15)
    result[:framework].should == :rails
    result[:engine].should == :ruby
    result[:features].size.should == 0
  end

  it "should detect rails 3.0 example 1" do
    result = run_matcher_on_fixture(16)
    result[:framework].should == :rails
    result[:engine].should == :ruby
    result[:features].should include :google_analytics
    result[:features].should include :facebook
    result[:features].size.should == 2
  end

  it "should detect rails 3.0 example 2" do
    result = run_matcher_on_fixture(17)
    result[:framework].should == :rails
    result[:engine].should == :ruby
    result[:features].should include :google_analytics
    result[:features].should include :facebook
    result[:features].size.should == 2
  end

  it "should detect rails 3.0 example 3" do
    result = run_matcher_on_fixture(18)
    result[:framework].should == :rails
    result[:engine].should == :ruby
    result[:features].should include :google_analytics
    result[:features].should include :facebook
    result[:features].size.should == 2
  end

  it "should detect e-target 1" do
    result = run_matcher_on_fixture(19)
    result[:doctype].should == "html public \"-//w3c//dtd html 4.01 transitional//en\""
    result[:features].should include :jquery
    result[:features].should include :google_analytics
    result[:features].should include :facebook
    result[:features].should include :etarget
    result[:features].size.should == 4
  end

  it "should detect e-target 2" do
    result = run_matcher_on_fixture(20)
    result[:doctype].should == "html public \"-//w3c//dtd xhtml 1.0 transitional//en\""
    result[:engine].should == :php
    result[:framework].should == :wordpress
    result[:features].should include :jquery
    result[:features].should include :google_analytics
    result[:features].should include :google_adsense
    result[:features].should include :facebook
    result[:features].should include :etarget
    result[:features].size.should == 5
  end

  it "should detect e-target 3" do
    result = run_matcher_on_fixture(21)
    result[:doctype].should == "html public \"-//w3c//dtd xhtml 1.0 strict//en\""
    result[:features].should include :etarget
    result[:features].size.should == 1
  end

  it "should detect google adsense 1" do
    result = run_matcher_on_fixture(22)
    result[:doctype].should == "html"
    result[:features].should include :jquery
    result[:features].should include :google_analytics
    result[:features].should include :google_adsense
    result[:features].size.should == 3
  end

  it "should detect google adsense 2" do
    result = run_matcher_on_fixture(23)
    result[:doctype].should == "html public \"-//w3c//dtd xhtml 1.0 strict//en\""
    result[:features].should include :mootools
    result[:features].should include :google_analytics
    result[:features].should include :google_adsense
    result[:features].size.should == 3
  end

  it "should detect ubercart 1" do
    result = run_matcher_on_fixture(24)
    result[:doctype].should == "html public \"-//w3c//dtd xhtml 1.0 strict//en\""
    result[:engine].should == :php
    result[:framework].should == :ubercart
    result[:features].should include :jquery
    result[:features].should include :google_analytics
    result[:features].size.should == 2
  end

  it "should detect ubercart 2" do
    result = run_matcher_on_fixture(25)
    result[:doctype].should == "html public \"-//w3c//dtd xhtml 1.0 strict//en\""
    result[:engine].should == :php
    result[:framework].should == :ubercart
    result[:features].should include :google_analytics
    result[:features].size.should == 1
  end
end
