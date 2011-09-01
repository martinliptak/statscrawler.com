module Helpers

  def run_matcher_on_fixture(fixture_num)
    headers = if File.exists?(File.dirname(__FILE__) + "/../models/fixtures/analyzer-#{fixture_num}.yaml")
                YAML::load(File.read(File.dirname(__FILE__) + "/../models/fixtures/analyzer-#{fixture_num}.yaml"))
              else
                {}
              end
    body = File.read(File.dirname(__FILE__) + "/../models/fixtures/analyzer-#{fixture_num}.html")

    matcher = Analyzers::Matcher.new
    matcher.match(headers, body)
  end
end