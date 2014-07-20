require 'uri'

class Location
  # Class Methods

  def self.create_table
    migrate = <<-SQL
      CREATE TABLE IF NOT EXISTS locations(
          id INTEGER PRIMARY KEY,
          latitude FLOAT,
          longitude FLOAT,
          map_name STRING
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

  def self.create(params)
    location = self.new(params)
    location.save
    location
  end

  # Instance Methods

  attr_reader :id, :map_name, :latitude, :longitude

  def initialize(params)
    normalize_params(params)
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
      VALUES (?, ?, ?)
    SQL
    DB[:conn].execute(insert, map_name, latitude, longitude)
    @id = DB[:conn].last_insert_row_id
  end

  def update
    update = <<-SQL
      UPDATE locations
      SET (map_name = ?, latitude = ?, longitude = ?)
      WHERE id = ?
    SQL
    DB[:conn].execute(update, id, map_name, latitude, longitude)
  end

  private

    def normalize_params(params)
      # Protect against HTML injection by encoding map_name
      @map_name = URI.encode(params[:map_name])
      # to_f would reject any HTML in the string already, so this is enough
      @latitude = params[:latitude].to_f
      @longitude = params[:longitude].to_f
    end
end