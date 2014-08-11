require './config/environment'
require 'sinatra/base'
require 'mailgun'
require 'uri'

class App < Sinatra::Base

  # config.yml file must be created first (in config folder)
  configure do
    if ENV['RACK_ENV'] == "development" || ENV['RACK_ENV'] == "test"
      yaml = YAML.load_file("config/config.yml")[settings.environment.to_s]
      yaml.each_pair do |key, value|
        set(key.to_sym, value)
      end
    else
      set(:google_maps_api_key, ENV['google_maps_api_key'])
      set(:mailgun_api_key, ENV['mailgun_api_key'])
      set(:mailgun_domain, ENV['mailgun_domain'])
      set(:twilio_account_sid, ENV['twilio_account_sid'])
      set(:twilio_auth_token, ENV['twilio_auth_token'])
    end
  end

  get '/' do
    erb :'index'
  end

  get '/error' do
    @error = error_msg(params[:msg])
    erb :'index'
  end

  get '/success' do
    @success = success_msg(params[:msg])
    erb :'index'
  end

  get '/:map_name' do
    @location = Location.find_by(map_name: params[:map_name])
    if @location
      erb :'show'
    else
      redirect to('/error?msg=map_not_found')
    end
  end

  post '/' do
    location = Location.new(location_params(params[:location]))
    if location.save
      msg = "map_saved"
      if params[:addresses] && params[:addresses].length > 0
        message_notice = send_messages(params[:addresses], location.map_name)
        if message_notice.include?("error")
          location.destroy
          redirect to("/error?msg=#{message_notice}")
        else
          msg << "_messages_sent"
        end
      end
      redirect to("/success?msg=#{msg}")
    else
      if location.errors[:map_name]
        redirect to('/error?msg=map_name_in_use')
      else
        redirect to('/error')
      end
    end
  end

  post '/show' do
    location = Location.find_by(map_name: normalize_map_name(params[:location][:map_name]))
    if location
      redirect to("/#{location.map_name}")
    else
      redirect to('/error?msg=map_not_found')
    end
  end


  private

    def location_params(location)
      whitelisted = {}
      # Protect against HTML injection by encoding map_name
      whitelisted[:map_name] = URI.encode(normalize_map_name(location[:map_name]))
      # to_f would reject any HTML in the string already, so this is enough
      whitelisted[:latitude] = location[:latitude].to_f
      whitelisted[:longitude] = location[:longitude].to_f

      whitelisted
    end

    def normalize_map_name(map_name)
      map_name.gsub(/\s+/, "-")
    end

    def error_msg(msg)
      case msg
        when "map_not_found"
          "Could not find map with that name."
        when "map_name_in_use"
          "There is already a map with that name.  Please choose another name."
        when "twilio_error"
          "Twilio Error.  Please verify the phone numbers are correct."
        else
          "There was an error with your request."
      end
    end

    def success_msg(msg)
      case msg
        when "map_saved"
          "Map saved successfully."
        when "map_saved_messages_sent"
          "Map saved and message(s) sent successfully."
      end
    end

    def send_messages(addresses, map_name)
      notice = "message_success"
      addresses.split("\r\n").each do |address|
        status = send_message(address, map_name)
        if status.include?("Error")
          notice = "twilio_error"
          break
        end
      end

      notice
    end

    def send_message(address, map_name)
      if !address.scan(/@/).empty?
        send_mail(address, map_name)
        notice = "Email sent successfully."
      else
        begin
          send_text(address, map_name)
          notice = "Text sent successfully."
        rescue
          notice = "Twilio Error.  Please verify phone numbers are correct."
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
                        :text => "CHECK IT > wheremeat.com/#{map_name}"
                       }
      mailgun.send_message(settings.mailgun_domain, message_params)
    end

    def send_text(address, map_name)
      @client = Twilio::REST::Client.new settings.twilio_account_sid, settings.twilio_auth_token
      message = @client.account.messages.create(
        :body => "WhereMeAt???  HereMeAt!!! CHECK IT > wheremeat.com/#{map_name}",
        :to => "#{address}",
        :from => "9735102922"
      )
    end
end