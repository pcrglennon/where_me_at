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
    context 'creating a map with a unique name' do
      before do
        post '/', {
          :location => {
            :map_name => 'a-test-map',
            :latitude => 42.0,
            :longitude => 42.0
          }
        }
        follow_redirect!
      end

      it 'responds with a 200 status code' do
        expect(last_response).to be_ok
      end

      it 'redirects to the page for the new map' do
        expect(last_request.url).to end_with('/a-test-map')
      end
    end

    context 'creating a map with a name already in use' do
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

      it 'responds with a 200 status code' do
        expect(last_response).to be_ok
      end

      it 'redirects back to the home page with an error message' do
        expect(last_request.url).to end_with('error?msg=map_name_in_use')
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