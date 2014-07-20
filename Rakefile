ENV["SINATRA_ENV"] ||= "development"

require './config/environment'

desc 'Load a pry console'
task :console do
  Pry.start
end

namespace :db do

  desc 'Migrate table'
  task :migrate do
    Location.create_table
  end

  desc 'Drop table'
  task :drop do
    Location.drop_table
  end

  desc 'Resets database'
  task :reset do
    Location.drop_table
    Location.create_table
  end

end