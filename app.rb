require './config/environment'
require 'sinatra/base'
require 'uri'

class App < Sinatra::Base

  def self.setupApiKeys
    configure do
      if ENV['RACK_ENV'] == "test" || ENV['RACK_ENV'] == "development"
        require 'yaml'
        ENV['google_maps_api_key'] = YAML.load_file("config/config.yml")[settings.environment.to_s]["google_maps_api_key"]
      end

      set :google_maps_api_key, ENV['google_maps_api_key']
      MessageHelper.setupConfig
    end
  end

  setupApiKeys

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
        message_notice = MessageHelper.send_messages(params[:addresses], location.map_name)
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
      map_name.gsub(/[.,\/#!$%\^&*;:{}=`~()]/, "").gsub(/\s+/, "-")
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

end