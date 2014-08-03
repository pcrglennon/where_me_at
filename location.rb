require 'uri'

class Location
  # Class Methods

  def self.attributes
    [:id, :map_name, :latitude, :longitude]
  end

  self.attributes.each { |a| attr_accessor a }

  def self.create_table
    migrate = <<-SQL
      CREATE TABLE IF NOT EXISTS locations(
        id SERIAL PRIMARY KEY,
        map_name TEXT,
        latitude FLOAT,
        longitude FLOAT
      );
    SQL
    DB[:conn].exec(migrate)
  end

  def self.drop_table
    drop = <<-SQL
      DROP TABLE IF EXISTS locations;
    SQL
    DB[:conn].exec(drop)
  end

  def self.map_name_exists?(map_name)
    select = <<-SQL
      SELECT * FROM locations
      WHERE map_name = $1;
    SQL
    row = DB[:conn].exec_params(select, [map_name]).values.flatten
    !row.empty?
  end

  def self.find_by_map_name(map_name)
    select = <<-SQL
      SELECT * FROM locations
      WHERE map_name = $1;
    SQL
    row = DB[:conn].exec_params(select, [map_name]).values.flatten
    if row.empty?
      nil
    else
      new_from_db(row)
    end
  end

  def self.new_from_db(row)
    self.new.tap do |location|
      row.each_with_index do |value, index|
        location.send("#{self.attributes[index]}=", value)
      end
    end
  end

  def self.create(params)
    location = self.new(params)
    location.save
    location
  end

  # Instance Methods

  def initialize(params = {})
    normalize_params(params) unless params.empty?
  end

  def save
    persisted? ? update : insert
  end

  def persisted?
    !!self.id
  end

  def insert
    insert = <<-SQL
      INSERT INTO locations (map_name, latitude, longitude)
      VALUES ($1, $2, $3)
      RETURNING id;
    SQL
    id = DB[:conn].exec_params(insert, [map_name, latitude, longitude]).values.flatten.first
    self.id = id
  end

  def update
    update = <<-SQL
      UPDATE locations
      SET (map_name = $1, latitude = $2, longitude = $3)
      WHERE id = $4;
    SQL
    DB[:conn].exec_params(update, [map_name, latitude, longitude, id])
  end

  private

    # Whitelist params + normalize
    def normalize_params(params)
      # Protect against HTML injection by encoding map_name
      @map_name = URI.encode(params[:map_name])
      # to_f would reject any HTML in the string already, so this is enough
      @latitude = params[:latitude].to_f
      @longitude = params[:longitude].to_f
    end
end