ENV['SINATRA_ENV'] ||= "development"

require 'bundler'
Bundler.require(:default, ENV['SINATRA_ENV'])

DB = {:conn => SQLite3::Database.new("./db/locations.db")}

require './location'