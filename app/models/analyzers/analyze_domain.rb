require 'resolv.rb'

module Analyzers
  class AnalyzeDomain < BaseAnalyzer
    @queue = 'high'

    def self.perform(domain_id)
      analyze(Domain.find(domain_id), 0)
    end
  end
end
