namespace :stats do
    task :daemon => :environment do
        Rails.logger = Logger.new(STDOUT)
        
        # ActiveRecord::Base.logger = Logger.new(STDOUT)
        # ActiveRecord::Base.logger.level = 0
    
        Analyzers::AnalyzeDomain.daemon
    end
end
