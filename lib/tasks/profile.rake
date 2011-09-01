task :profile => :environment do
  result = RubyProf.profile do
    Analyzers::AnalyzeDomain.daemon(0)
  end

  printer = RubyProf::GraphPrinter.new(result)
  printer.print(STDOUT, :min_percent => 10)
end