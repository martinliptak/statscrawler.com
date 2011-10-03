module Analyzers

  class AnalyzeAllDomains < AnalyzeDomain
    @queue = 'low'

    def self.perform(thread_count = 63)
      if thread_count > 0
        Thread.abort_on_exception = true

        queue = SizedQueue.new(thread_count)

        threads = []
        thread_count.times { |i|
          threads << Thread.new(i) { |id|
            while true
              analyze(queue.shift, id)
            end
          }
        }

        begin
          Domain.to_be_analyzed.find_each { |record|
            queue << record
          }
        rescue NoMethodError
          retry
        end
      else
        Domain.to_be_analyzed.find_each { |record|
          analyze(record)
        }
      end
    end
  end
end
