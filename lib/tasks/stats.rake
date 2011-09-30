namespace :stats do
    task :common => :environment do
        Rails.logger = Logger.new(STDOUT)
        
        #ActiveRecord::Base.logger = Logger.new(STDOUT)
        #ActiveRecord::Base.logger.level = 0
    end

    namespace :analyzers do
      task :all => :common do
          Resque::enqueue(Analyzers::AnalyzeAllDomains)
      end
      
      task :all_now => :common do
          Analyzers::AnalyzeAllDomains.perform
      end
    end
    
    namespace :parsers do
        task :sk_nic => :common do
            Resque::enqueue(Parsers::SkNicParser)
        end
        
        task :ceske_domeny_info => :common do
            Resque::enqueue(Parsers::CeskeDomenyInfoParser)
        end
        
        task :dmoz => :common do
            Resque::enqueue(Parsers::DmozParser)
        end
    end
end
