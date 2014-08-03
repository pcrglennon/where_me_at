ENV['RACK_ENV'] ||= "development"

require 'bundler'
Bundler.require(:default, ENV['RACK_ENV'])
require 'yaml'
require 'sinatra/base'

configure :development, :production do
  db = URI.parse(ENV['DATABASE_URL'] || 'postgres://localhost/wheremeat_development')

  ActiveRecord::Base.establish_connection(
      :adapter => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
      :host     => db.host,
      :username => db.user,
      :password => db.password,
      :database => db.path[1..-1],
      :encoding => 'utf8'
  )
end

require_relative '../location'
