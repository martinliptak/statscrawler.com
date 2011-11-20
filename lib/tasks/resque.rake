require "#{File.dirname(__FILE__)}/../../config/environment"

Rails.logger = Logger.new(STDOUT)

require 'resque/tasks'
