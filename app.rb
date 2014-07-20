require './config/environment'

class App < Sinatra::Base
  get '/' do
    erb :'index'
  end

  get '/:map_name' do

  end

  post '/' do
    location = Location.new(params[:location])
    # TODO - validate that SQL was executed correctly!
    location.save
    redirect to("/#{location.map_name}")
  end
end