module Helpers

  def run_matcher_on_fixture(fixture)
    headers = if File.exists?(File.dirname(__FILE__) + "/../models/fixtures/matcher/#{fixture}.yaml")
                YAML::load(File.read(File.dirname(__FILE__) + "/../models/fixtures/matcher/#{fixture}.yaml"))
              else
                {}
              end
    body = File.read(File.dirname(__FILE__) + "/../models/fixtures/matcher/#{fixture}.html")

    matcher = Analyzers::Matcher.new
    matcher.match(headers, body)
  end
end