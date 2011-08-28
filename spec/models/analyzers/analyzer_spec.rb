require 'spec_helper'

describe Analyzers::Analyzer do

  it "should detect facebook 1" do
    headers = YAML::load(File.read(File.dirname(__FILE__) + '/../fixtures/analyzer-1.yaml'))
    body = File.read(File.dirname(__FILE__) + '/../fixtures/analyzer-1.html')

    analyzer = Analyzers::Analyzer.new(headers, body)
    result = analyzer.run
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
    headers = YAML::load(File.read(File.dirname(__FILE__) + '/../fixtures/analyzer-2.yaml'))
    body = File.read(File.dirname(__FILE__) + '/../fixtures/analyzer-2.html')

    analyzer = Analyzers::Analyzer.new(headers, body)
    result = analyzer.run
    result[:server].should == :nginx
    result[:engine].should == :php
    result[:doctype].should == "html public \"-//w3c//dtd xhtml 1.0 strict//en\""
    result[:features].should include :mootools
    result[:features].should include :facebook
    result[:features].should include :google_analytics
    result[:features].size.should == 3
  end

  it "should detect facebook 3" do
    headers = YAML::load(File.read(File.dirname(__FILE__) + '/../fixtures/analyzer-3.yaml'))
    body = File.read(File.dirname(__FILE__) + '/../fixtures/analyzer-3.html')

    analyzer = Analyzers::Analyzer.new(headers, body)
    result = analyzer.run
    result[:server].should == :nginx
    result[:engine].should == :php
    result[:doctype].should == "html public \"-//w3c//dtd xhtml 1.0 transitional//en\""
    result[:framework].should == :wordpress
    result[:features].should include :jquery
    result[:features].should include :facebook
    result[:features].size.should == 2
  end

  it "should detect drupal 1" do
    headers = YAML::load(File.read(File.dirname(__FILE__) + '/../fixtures/analyzer-4.yaml'))
    body = File.read(File.dirname(__FILE__) + '/../fixtures/analyzer-4.html')

    analyzer = Analyzers::Analyzer.new(headers, body)
    result = analyzer.run
    result[:server].should == :apache
    result[:framework].should == :drupal
    result[:engine].should == :php
    result[:doctype].should == "html public \"-//w3c//dtd xhtml 1.0 strict//en\""
    result[:features].should include :jquery
    result[:features].size.should == 1
  end

  it "should detect drupal 2" do
    headers = YAML::load(File.read(File.dirname(__FILE__) + '/../fixtures/analyzer-5.yaml'))
    body = File.read(File.dirname(__FILE__) + '/../fixtures/analyzer-5.html')

    analyzer = Analyzers::Analyzer.new(headers, body)
    result = analyzer.run
    result[:server].should == :apache
    result[:framework].should == :drupal
    result[:engine].should == :php
    result[:doctype].should == "html public \"-//w3c//dtd xhtml 1.0 strict//en\""
    result[:features].should include :jquery
    result[:features].size.should == 1
  end

  it "should detect drupal 3" do
    headers = YAML::load(File.read(File.dirname(__FILE__) + '/../fixtures/analyzer-6.yaml'))
    body = File.read(File.dirname(__FILE__) + '/../fixtures/analyzer-6.html')

    analyzer = Analyzers::Analyzer.new(headers, body)
    result = analyzer.run
    result[:server].should == :apache
    result[:framework].should == :drupal
    result[:engine].should == :php
    result[:doctype].should == "html public \"-//w3c//dtd xhtml 1.0 strict//en\""
  end

  it "should detect drupal 4" do
    headers = YAML::load(File.read(File.dirname(__FILE__) + '/../fixtures/analyzer-7.yaml'))
    body = File.read(File.dirname(__FILE__) + '/../fixtures/analyzer-7.html')

    analyzer = Analyzers::Analyzer.new(headers, body)
    result = analyzer.run
    result[:framework].should == :drupal
    result[:engine].should == :php
    result[:doctype].should == "html public \"-//w3c//dtd xhtml 1.0 strict//en\""
    result[:features].should include :jquery
    result[:features].should include :google_analytics
    result[:features].size.should == 2
  end

  it "should detect drupal 5" do
    headers = YAML::load(File.read(File.dirname(__FILE__) + '/../fixtures/analyzer-8.yaml'))
    body = File.read(File.dirname(__FILE__) + '/../fixtures/analyzer-8.html')

    analyzer = Analyzers::Analyzer.new(headers, body)
    result = analyzer.run
    result[:framework].should == :drupal
    result[:engine].should == :php
    result[:doctype].should == "html public \"-//w3c//dtd xhtml 1.0 strict//en\""
    result[:features].should include :jquery
    result[:features].should include :google_analytics
    result[:features].size.should == 2
  end

  it "should detect drupal 6" do
    body = File.read(File.dirname(__FILE__) + '/../fixtures/analyzer-9.html')

    analyzer = Analyzers::Analyzer.new({}, body)
    result = analyzer.run
    result[:framework].should == :drupal
    result[:doctype].should == "html public \"-//w3c//dtd xhtml+rdfa 1.0//en\""
    result[:features].should include :jquery
    result[:features].size.should == 1
  end

  it "should detect drupal 7" do
    body = File.read(File.dirname(__FILE__) + '/../fixtures/analyzer-10.html')

    analyzer = Analyzers::Analyzer.new({}, body)
    result = analyzer.run
    result[:framework].should == :drupal
    result[:doctype].should == "html public \"-//w3c//dtd xhtml 1.0 strict//en\""
  end

  it "should detect prestashop 1" do
    body = File.read(File.dirname(__FILE__) + '/../fixtures/analyzer-11.html')

    analyzer = Analyzers::Analyzer.new({}, body)
    result = analyzer.run
    result[:framework].should == :prestashop
    result[:doctype].should == "html public \"-//w3c//dtd xhtml 1.1//en\""
  end

  it "should detect prestashop 2" do
    body = File.read(File.dirname(__FILE__) + '/../fixtures/analyzer-12.html')

    analyzer = Analyzers::Analyzer.new({}, body)
    result = analyzer.run
    result[:framework].should == :prestashop
    result[:doctype].should == "html public \"-//w3c//dtd xhtml 1.1//en\""
  end

  it "should detect opencart 1" do
    body = File.read(File.dirname(__FILE__) + '/../fixtures/analyzer-13.html')

    analyzer = Analyzers::Analyzer.new({}, body)
    result = analyzer.run
    result[:framework].should == :opencart
    result[:doctype].should == "html public \"-//w3c//dtd xhtml 1.0 strict//en\""
  end

  it "should detect opencart 2" do
    body = File.read(File.dirname(__FILE__) + '/../fixtures/analyzer-14.html')

    analyzer = Analyzers::Analyzer.new({}, body)
    result = analyzer.run
    result[:framework].should == :opencart
    result[:doctype].should == "html public \"-//w3c//dtd xhtml 1.0 strict//en\""
  end

  it "should detect rails 3.1" do
    body = File.read(File.dirname(__FILE__) + '/../fixtures/analyzer-15.html')

    analyzer = Analyzers::Analyzer.new({}, body)
    result = analyzer.run
    result[:framework].should == :rails
    result[:engine].should == :ruby
    result[:features].size.should == 0
  end

  it "should detect rails 3.0 example 1" do
    body = File.read(File.dirname(__FILE__) + '/../fixtures/analyzer-16.html')

    analyzer = Analyzers::Analyzer.new({}, body)
    result = analyzer.run
    result[:framework].should == :rails
    result[:engine].should == :ruby
    result[:features].should include :google_analytics
    result[:features].should include :facebook
    result[:features].size.should == 2
  end

  it "should detect rails 3.0 example 2" do
    body = File.read(File.dirname(__FILE__) + '/../fixtures/analyzer-17.html')

    analyzer = Analyzers::Analyzer.new({}, body)
    result = analyzer.run
    result[:framework].should == :rails
    result[:engine].should == :ruby
    result[:features].should include :google_analytics
    result[:features].should include :facebook
    result[:features].size.should == 2
  end

  it "should detect rails 3.0 example 3" do
    body = File.read(File.dirname(__FILE__) + '/../fixtures/analyzer-18.html')

    analyzer = Analyzers::Analyzer.new({}, body)
    result = analyzer.run
    result[:framework].should == :rails
    result[:engine].should == :ruby
    result[:features].should include :google_analytics
    result[:features].should include :facebook
    result[:features].size.should == 2
  end

  it "should detect e-target 1" do
    body = File.read(File.dirname(__FILE__) + '/../fixtures/analyzer-19.html')

    analyzer = Analyzers::Analyzer.new({}, body)
    result = analyzer.run
    result[:doctype].should == "html public \"-//w3c//dtd html 4.01 transitional//en\""
    result[:features].should include :jquery
    result[:features].should include :google_analytics
    result[:features].should include :facebook
    result[:features].should include :etarget
    result[:features].size.should == 4
  end

  it "should detect e-target 2" do
    body = File.read(File.dirname(__FILE__) + '/../fixtures/analyzer-20.html')

    analyzer = Analyzers::Analyzer.new({}, body)
    result = analyzer.run
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
    body = File.read(File.dirname(__FILE__) + '/../fixtures/analyzer-21.html')

    analyzer = Analyzers::Analyzer.new({}, body)
    result = analyzer.run
    result[:doctype].should == "html public \"-//w3c//dtd xhtml 1.0 strict//en\""
    result[:features].should include :etarget
    result[:features].size.should == 1
  end

  it "should detect google adsense 1" do
    body = File.read(File.dirname(__FILE__) + '/../fixtures/analyzer-22.html')

    analyzer = Analyzers::Analyzer.new({}, body)
    result = analyzer.run
    result[:doctype].should == "html"
    result[:features].should include :jquery
    result[:features].should include :google_analytics
    result[:features].should include :google_adsense
    result[:features].size.should == 3
  end

  it "should detect google adsense 2" do
    body = File.read(File.dirname(__FILE__) + '/../fixtures/analyzer-23.html')

    analyzer = Analyzers::Analyzer.new({}, body)
    result = analyzer.run
    result[:doctype].should == "html public \"-//w3c//dtd xhtml 1.0 strict//en\""
    result[:features].should include :mootools
    result[:features].should include :google_analytics
    result[:features].should include :google_adsense
    result[:features].size.should == 3
  end

  it "should detect ubercart 1" do
    body = File.read(File.dirname(__FILE__) + '/../fixtures/analyzer-24.html')

    analyzer = Analyzers::Analyzer.new({}, body)
    result = analyzer.run
    result[:doctype].should == "html public \"-//w3c//dtd xhtml 1.0 strict//en\""
    result[:engine].should == :php
    result[:framework].should == :ubercart
    result[:features].should include :jquery
    result[:features].should include :google_analytics
    result[:features].size.should == 2
  end

  it "should detect ubercart 2" do
    body = File.read(File.dirname(__FILE__) + '/../fixtures/analyzer-25.html')

    analyzer = Analyzers::Analyzer.new({}, body)
    result = analyzer.run
    result[:doctype].should == "html public \"-//w3c//dtd xhtml 1.0 strict//en\""
    result[:engine].should == :php
    result[:framework].should == :ubercart
    result[:features].should include :google_analytics
    result[:features].size.should == 1
  end
end
