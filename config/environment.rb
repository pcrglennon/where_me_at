ENV['SINATRA_ENV'] ||= "development"

require 'bundler'
Bundler.require(:default, ENV['SINATRA_ENV'])
require 'yaml'
require 'sinatra/base'

if ENV['SINATRA_ENV'] == "development"
  DB = {:conn => SQLite3::Database.new("./db/locations.db")}
else
  console.log(ENV)
  # DB = {:conn => PG.connect()}
end

require_relative '../location'
