require_relative 'spec_helper'

describe Location do

  before do
    Location.create_table
  end

  after do
    Location.drop_table
  end

end