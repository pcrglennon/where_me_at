ENV['SINATRA_ENV'] ||= "development"

require 'bundler'
Bundler.require(:default, ENV['SINATRA_ENV'])

DB = SQLite3::Database.open "locations.db"

require 'yaml'

configure do
  yaml = YAML.load_file("config/config.yml")[settings.environment.to_s]
  yaml.each_pair do |key, value|
    set(key.to_sym, value)
  end
end

require './db/migrate/01_create_locations'
require './app'
