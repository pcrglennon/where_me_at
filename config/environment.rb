ENV['SINATRA_ENV'] ||= "development"

require 'bundler'
Bundler.require(:default, ENV['SINATRA_ENV'])

DB = {:conn => SQLite3::Database.new("./db/locations.db")}

require 'yaml'

# config.yml file must be created first (in config folder)
configure do
  yaml = YAML.load_file("config/config.yml")[settings.environment.to_s]
  yaml.each_pair do |key, value|
    set(key.to_sym, value)
  end
end

require './location'