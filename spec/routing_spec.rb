require_relative 'spec_helper'
require_relative '../app'

describe 'Routes' do
  include Rack::Test::Methods

  def app
    App.new
  end

  describe 'GET /' do
    before do
      get '/'
    end

    it 'responds with a 200 status code' do
      expect(last_response).to be_ok
    end
  end

  describe 'POST /' do
    before do
      @location_params = {map_name: "a-test-map", latitude: 42.0, longitude: 42.0}
    end

    context 'creating a map with a unique name' do
      before do
        post '/', {
          location: @location_params
        }
        follow_redirect!
      end

      it 'responds with a 200 status code' do
        expect(last_response).to be_ok
      end

      it 'redirects to the page for the new map' do
        expect(last_request.url).to end_with('/a-test-map')
      end

      context 'and sending messages' do
        context 'to a valid phone number' do
          before do
            post '/', {
              location: @location_params,
              addresses: [5555555555]
            }
          end

          it 'responds with a 200 status code' do
            expect(last_response).to be_ok
          end

          it 'redirects back to the home page with a success message' do
            expect(last_request.path).to eq("/")
            expect(last_response.body).to include('Message(s) sent successfully')
          end
        end
      end
    end

    context 'creating a map with a name already in use' do
      before do
        Location.create(:map_name => 'a-test-map', :latitude => 42.0, :longitude => 42.0)
        post '/', {
          location: @location_params
        }
        follow_redirect!
      end

      it 'responds with a 200 status code' do
        expect(last_response).to be_ok
      end

      it 'redirects back to the home page with an error message' do
        expect(last_request.path).to eq("/error")
        expect(last_request.query_string).to eq("msg=map_name_in_use")
        expect(last_response.body).to include('There is already a map with that name.')
      end

      it 'does not create another map with the same name, and does not override the original' do
        expect(Location.where(map_name: "a-test-map").size).to eq(1)
        expect(Location.find_by(map_name: "a-test-map").latitude).to eq(42.0)
      end
    end

    context 'creating a map and sending' do
      before do
        Location.create(:map_name => 'a-test-map', :latitude => 42.0, :longitude => 42.0)
        post '/', {
          :location => {
            :map_name => 'a-test-map',
            :latitude => 0.0,
            :longitude => 0.0
          }
        }
        follow_redirect!
      end
    end
  end

  describe 'GET /:map_name' do
    before do
      Location.create(:map_name => 'a-test-map-get', :latitude => 42.0, :longitude => 42.0)
      get '/a-test-map-get'
    end

    it 'responds with a 200 status code' do
      expect(last_response).to be_ok
    end

    it 'shows the correct map' do
      expect(last_response.body).to include('a-test-map-get')
    end
  end

end