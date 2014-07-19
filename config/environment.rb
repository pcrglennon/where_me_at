require 'bundler'
Bundle.require(:default)

DB = SQLite3::Database.open "locations.db"

require 'app'
require 'db/migrate/01_create_locations'