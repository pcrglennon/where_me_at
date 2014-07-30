require './config/environment'
require 'sinatra/base'
require 'mailgun'

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

  get '/error' do
    @notice = "The map name was wrong"
    erb :'index'
  end

  post '/' do
    location = Location.new(params[:location])
    # TODO - validate that SQL was executed correctly!
    location.save
    redirect to("/#{location.map_name}")
  end

  post '/show' do
    location = Location.find_by_map_name(params[:location][:map_name])
    if location
      redirect to("/#{location.map_name}")
    else
      redirect to('/error')
    end
  end

  post '/:map_name/send_link' do
    address = params[:address]
    map_name = params[:map_name]
    if !address.scan(/@/).empty?
      mailgun = Mailgun::Client.new(settings.mailgun_api_key)
      message_params = {:from => "test@#{settings.mailgun_domain}",
                        :to => address,
                        :subject => "WhereMeAt???  HereMeAt!!!",
                        :text => "CHECK IT > localhost:9292/#{map_name}"
                       }
      mailgun.send_message(settings.mailgun_domain, message_params)
    else
      begin
      @client = Twilio::REST::Client.new settings.twilio_account_sid, settings.twilio_auth_token
      message = @client.account.messages.create(
        :body => "WhereMeAt???  HereMeAt!!! CHECK IT > localhost:9292/#{map_name}",
        :to => "#{address}",
        :from => "9735102922"
        )
      puts message.to
      rescue
        redirect to("/#{map_name}")
      end
    end
    @notice = "Message sent!"
    redirect to("/#{map_name}")
  end

  get '/:map_name' do
    @location = Location.find_by_map_name(params[:map_name])
    if @location
      erb :'show'
    else
      redirect to('/error')
    end
  end

end