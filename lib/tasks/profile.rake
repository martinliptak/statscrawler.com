require "#{File.dirname(__FILE__)}/../../config/environment"

namespace :stats do
  task :profile do
    result = RubyProf.profile do
      Analyzers::MassPerformer.perform(false)
    end

    printer = RubyProf::GraphPrinter.new(result)
    printer.print(STDOUT, :min_percent => 10)
  end
end