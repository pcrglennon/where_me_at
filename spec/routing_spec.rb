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

    describe 'creating a map with a unique name' do
      before do
        post '/', {
          location: @location_params
        }
        follow_redirect!
      end

      it 'responds with a 200 status code' do
        expect(last_response).to be_ok
      end

      it 'redirects to the success page' do
        expect(last_request.path).to eq('/success')
        expect(last_response.body).to include('Map saved successfully.')
      end
    end

    describe 'sending messages' do
      context 'to a valid phone number' do
        before do
          post '/', {
            location: @location_params,
            # Took this phone # from the Twilio Testing docs!
            addresses: "14108675309"
          }
          follow_redirect!
        end

        it 'responds with a 200 status code' do
          expect(last_response).to be_ok
        end

        it 'redirects back to the home page with a success message' do
          expect(last_request.path).to eq('/success')
          expect(last_response.body).to include('Map saved and message(s) sent successfully.')
        end
      end

      context 'to a valid phone number and email address' do
        before do
          post '/', {
            location: @location_params,
            addresses: "14108675309\r\nfoo@bar.com"
          }
          follow_redirect!
        end

        it 'responds with a 200 status code' do
          expect(last_response).to be_ok
        end

        it 'redirects back to the home page with a success message' do
          expect(last_request.path).to eq('/success')
          expect(last_response.body).to include('Map saved and message(s) sent successfully.')
        end
      end

      context 'to an invalid phone number' do
        before do
          post '/', {
            location: @location_params,
            addresses: "5555"
          }
          follow_redirect!
        end

        it 'responds with a 200 status code' do
          expect(last_response).to be_ok
        end

        it 'redirects back to the home page with an error message' do
          expect(last_request.path).to eq("/error")
          expect(last_response.body).to include('Twilio Error.')
        end

        it 'deletes the created map, so the user can create it again' do
          expect(Location.find_by(map_name: "a-test-map")).to be(nil)
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
  end

  describe 'GET /:map_name' do
    before do
      Location.create(:map_name => 'a-test-map', :latitude => 42.0, :longitude => 42.0)
      get '/a-test-map'
    end

    it 'responds with a 200 status code' do
      expect(last_response).to be_ok
    end

    it 'shows the correct map' do
      expect(last_response.body).to include('a test map')
    end
  end

end