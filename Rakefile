ENV["RACK_ENV"] ||= "development"

require './config/environment'
require "sinatra/activerecord/rake"

desc 'Load a pry console'
task :console do
  Pry.start
end

desc 'Deletes all saved locations older than 2 hours'
task :purge_locations do
  Location.where('created_at < ?', 2.hours.ago).each do |location|
    location.destroy
  end
end