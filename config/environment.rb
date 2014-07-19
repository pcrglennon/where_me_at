require 'bundler'
Bundle.require(:default)

DB = SQLite3::Database.open "locations.db"

require 'app'