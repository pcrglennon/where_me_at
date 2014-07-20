require_relative 'spec_helper'

describe Location do
  include Rack::Test::Methods

  before do
    Location.create_table
  end

  after do
    Location.drop_table
  end

  it 'is a test' do
    expect(1).to eq(1)
  end

end