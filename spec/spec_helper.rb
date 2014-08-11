require 'simplecov'
SimpleCov.start

ENV['RACK_ENV'] = "test"

require_relative '../config/environment'

RSpec.configure do |config|

  ActiveRecord::Base.logger = nil

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

end

