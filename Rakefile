ENV["RACK_ENV"] ||= "development"

require './config/environment'
require "sinatra/activerecord/rake"

desc 'Load a pry console'
task :console do
  Pry.start
end