ENV['SINATRA_ENV'] ||= "development"

require 'bundler'
Bundler.require(:default, ENV['SINATRA_ENV'])
require 'yaml'
require 'sinatra/base'

DB = {:conn => SQLite3::Database.new("./db/locations.db")}

require_relative '../location'
