source 'https://rubygems.org'
gem 'sinatra'
gem 'activerecord'
gem 'sinatra-activerecord'
gem 'thin'
gem 'rake'
gem 'twilio-ruby'
gem 'mailgun-ruby'

group :test, :development do
  gem 'pry'
  gem 'shotgun'
  gem 'rspec'
  gem 'capybara'
  gem 'rack-test'
end

group :development, :production do
  gem 'pg'
end

group :test do
  gem 'sqlite3'
  gem 'database_cleaner'
  gem 'simplecov', :require => false
  gem 'coveralls', :require => false
end