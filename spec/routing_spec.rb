require_relative 'spec_helper'
require_relative '../app'

describe 'Routes' do
  include Rack::Test::Methods

  def app
    App.new
  end

  before do
    Location.create_table
  end

  after do
    Location.drop_table
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