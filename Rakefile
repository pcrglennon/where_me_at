ENV["SINATRA_ENV"] ||= "development"

require './config/environment'

desc 'Load a pry console'
task :console => [:environment] do
  Pry.start
end