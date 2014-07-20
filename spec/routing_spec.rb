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
      post '/', {
        :name => 'a-test-map',
        :latitude => 42.0,
        :longitude => 42.0
      }
      follow_redirect!
    end

    it 'responds with a 200 status code' do
      expect(last_response).to be_ok
    end

    it 'redirects to the page for the new map' do
      expect(last_request.location).to end_with('/a-test-map')
    end
  end

  describe 'GET /:map-name' do
    before do
      Location.create(:name => 'a-test-map', :latitude => 42.0, :longitude => 42.0)
      get '/a-test-map'
    end

    it 'responds with a 200 status code' do
      expect(last_response).to be_ok
    end

    it 'shows the correct map' do
      expect(last_response.body).to include('a-test-map')
    end
  end

end