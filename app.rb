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
    msg = params[:msg]
    @error = error_msg(msg)
    erb :'index'
  end

  get '/:map_name' do
    @location = Location.find_by_map_name(params[:map_name])
    if @location
      erb :'show'
    else
      redirect to('/error?msg=map_not_found')
    end
  end

  post '/' do
    location_params = params[:location]
    if Location.map_name_exists?(location_params[:map_name])
      redirect to('/error?msg=map_name_in_use')
    end
    location = Location.new(location_params)
    # TODO - validate that SQL was executed correctly!
    location.save
    redirect to("/#{location.map_name}")
  end

  post '/show' do
    location = Location.find_by_map_name(params[:location][:map_name])
    if location
      redirect to("/#{location.map_name}")
    else
      redirect to('/error?msg=map_not_found')
    end
  end

  post '/:map_name/send_link' do
    address = params[:address]
    map_name = params[:map_name]
    @notice = send_message(address, map_name)
    redirect to("/#{map_name}")
  end

  private

    def error_msg(msg)
      case msg
        when "map_not_found"
          "Could not find map with that name."
        when "map_name_in_use"
          "There is already a map with that name.  Please choose another name."
        else
          "There was an error with your request."
      end
    end

    def send_message(address, map_name)
      notice = nil
      if !address.scan(/@/).empty?
        send_mail(address, map_name)
        notice = "Email sent successfully."
      else
        begin
          send_text(address, map_name)
          notice = "Text sent successfully."
        rescue
          notice = "Twilio Error.  Please try again."
        end
      end

      notice
    end

    def send_mail(address, map_name)
      mailgun = Mailgun::Client.new(settings.mailgun_api_key)
      message_params = {
                        :from => "test@#{settings.mailgun_domain}",
                        :to => address,
                        :subject => "WhereMeAt???  HereMeAt!!!",
                        :text => "CHECK IT > localhost:9292/#{map_name}"
                       }
      mailgun.send_message(settings.mailgun_domain, message_params)
    end

    def send_text(address, map_name)
      @client = Twilio::REST::Client.new settings.twilio_account_sid, settings.twilio_auth_token
      message = @client.account.messages.create(
        :body => "WhereMeAt???  HereMeAt!!! CHECK IT > localhost:9292/#{map_name}",
        :to => "#{address}",
        :from => "9735102922"
      )
      puts message.to
    end

end