class CreateLocations

  def self.migrate
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

  def self.drop
    drop = <<-SQL
      DROP TABLE IF EXISTS locations;
    SQL
    DB[:conn].execute(drop)
  end

end