require './config/environment'

class App < Sinatra::Base
  get '/' do
    erb :'index'
  end

  get '/:map_name' do
    @location = Location.find_by_map_name(params[:map_name])
    if @location
      erb :'show'
    else
      redirect_to('/')
    end
  end

  post '/' do
    location = Location.new(params[:location])
    # TODO - validate that SQL was executed correctly!
    location.save
    redirect to("/#{location.map_name}")
  end
end