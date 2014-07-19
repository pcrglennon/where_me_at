ENV["SINATRA_ENV"] ||= "development"

require './config/environment'

desc 'Load a pry console'
task :console => [:environment] do
  Pry.start
end

namespace :db do

  desc 'Migrate table'
  task :migrate do
    ::Sequel.extension :migration
    Sequel::Migrator.run DB, 'db/migrate'
    puts '<= db:migrate executed'
  end

  desc 'Drop table'
  task :drop do

  end

  desc 'Seed database'
  task :seed do

  end

  desc 'Resets database'
  task :reset do

  end

end