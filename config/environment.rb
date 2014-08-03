ENV['SINATRA_ENV'] ||= "development"

require 'bundler'
Bundler.require(:default, ENV['SINATRA_ENV'])
require 'yaml'
require 'sinatra/base'

# DB = {:conn => SQLite3::Database.new("./db/locations.db")}

configure :development, :production do
  DB = {:conn => PG.connect(dbname: 'wheremeat_development')}
end

require_relative '../location'
