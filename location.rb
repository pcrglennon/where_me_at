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
        id INTEGER PRIMARY KEY,
        map_name STRING,
        latitude FLOAT,
        longitude FLOAT
      );
    SQL
    DB[:conn].execute(migrate)
  end

  def self.drop_table
    drop = <<-SQL
      DROP TABLE IF EXISTS locations;
    SQL
    DB[:conn].execute(drop)
  end

  def self.map_name_exists?(map_name)
    select = <<-SQL
      SELECT * FROM locations
      WHERE map_name = ?;
    SQL
    row = DB[:conn].execute(select, map_name).flatten
    !row.empty?
  end

  def self.find_by_map_name(map_name)
    select = <<-SQL
      SELECT * FROM locations
      WHERE map_name = ?;
    SQL
    row = DB[:conn].execute(select, map_name).flatten
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
      VALUES (?, ?, ?);
    SQL
    DB[:conn].execute(insert, map_name, latitude, longitude)
    self.id = DB[:conn].last_insert_row_id
  end

  def update
    update = <<-SQL
      UPDATE locations
      SET (map_name = ?, latitude = ?, longitude = ?)
      WHERE id = ?;
    SQL
    DB[:conn].execute(update, id, map_name, latitude, longitude)
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