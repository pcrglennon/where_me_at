ENV["SINATRA_ENV"] ||= "development"

require './config/environment'

desc 'Load a pry console'
task :console => [:environment] do
  Pry.start
end

namespace :db do

  desc 'Migrate table'
  task :migrate => [:environment] do
    CreateLocations.migrate if defined?(CreateLocations)
  end

  desc 'Drop table'
  task :drop do
    CreateLocations.drop if defined?(CreateLocations)
  end

  desc 'Resets database'
  task :reset do
    if defined?(CreateLocations)
      CreateLocations.drop
      CreateLocations.migrate
    end
  end

end