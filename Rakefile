ENV["RACK_ENV"] ||= "development"

require './config/environment'
require "sinatra/activerecord/rake"

desc 'Load a pry console'
task :console do
  Pry.start
end

namespace :db do
  desc 'Deletes all saved locations older than 2 hours'
  task :purge_locations do
    Location.where('created_at < ?', 2.hours.ago.utc).each do |location|
      location.destroy
    end
  end
end


# Rake task to run Rspec
begin
  require "rspec/core/rake_task"

  desc "Run all examples"
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.rspec_opts = %w[--color]
    t.pattern = 'spec/*_spec.rb'
  end
rescue LoadError
end