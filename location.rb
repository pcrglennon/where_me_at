class Location < ActiveRecord::Base

  def denormalized_name
    self.map_name.gsub('-', ' ')
  end

end