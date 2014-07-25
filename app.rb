require './config/environment'
require 'yaml'

class App < Sinatra::Base

  # config.yml file must be created first (in config folder)
  configure do
    yaml = YAML.load_file("config/config.yml")[settings.environment.to_s]
    yaml.each_pair do |key, value|
      set(key.to_sym, value)
    end
  end

  get '/' do
    erb :'index'
  end

  post '/' do
    location = Location.new(params[:location])
    # TODO - validate that SQL was executed correctly!
    location.save
    redirect to("/#{location.map_name}")
  end

  get '/:map_name' do
    @location = Location.find_by_map_name(params[:map_name])
    if @location
      erb :'show'
    else
      redirect to('/')
    end
  end

end