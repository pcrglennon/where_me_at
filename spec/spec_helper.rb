ENV['SINATRA_ENV'] = 'test'

require_relative '../config/environment'

DB[:conn] = SQLite3::Database.new(":memory:")