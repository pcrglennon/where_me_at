require 'bundler'
Bundler.require(:default)

DB = SQLite3::Database.open "locations.db"

configure do
  yaml = YAML.load_file(settings.config + "/config.yaml")[settings.environment.to_s]
  yaml.each_pair do |key, value|
    set(key.to_sym, value)
  end
end

require 'app'