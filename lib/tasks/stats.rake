namespace :stats do
    task :daemon => :environment do
        Analyzers::AnalyzeDomain.daemon
    end
end