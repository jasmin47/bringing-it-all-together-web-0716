require_relative "../config/environment.rb"

class Dog
  attr_accessor :name, :breed, :id

def initialize(id: nil, name:, breed:)
  @id = id
  @name = name
  @breed = breed
end

def self.create_table
sql = <<-SQL
CREATE TABLE IF NOT EXISTS dogs(
  id INTEGER PRIMARY KEY,
  name TEXT,
  breed TEXT
);
SQL
DB[:conn].execute(sql)
end

def self.drop_table
  sql = <<-SQL
  DROP TABLE dogs;
  SQL
DB[:conn].execute(sql)
end

def save
  if self.id
    self.update
  else
sql = <<-SQL
INSERT INTO dogs(name, breed)
VALUES(?,?);
SQL
DB[:conn].execute(sql, @name, @breed)
@id = DB[:conn].execute("SELECT id FROM dogs ORDER BY id DESC LIMIT 1")[0][0]
self
end
end

def self.create(name:, breed:)
  new_dog = Dog.new(name: name, breed: breed)
  new_dog.save
  new_dog
end

def self.find_by_id(id)
  sql = <<-SQL
  SELECT * FROM dogs WHERE id = ?
  SQL
  dog = DB[:conn].execute(sql, id)[0]
  new_dog = self.new(id: dog[0], name: dog[1], breed: dog[2])
  new_dog
end

def self.new_from_db(dog)
  new_dog = Dog.new(name: dog[1], breed: dog[2])
  new_dog.save
  new_dog
end

def self.find_by_name(name)
  sql = <<-SQL
  SELECT * FROM dogs
  WHERE name = ?;
  SQL
  dog = DB[:conn].execute(sql, name)[0]
  new_dog = Dog.new(id: dog[0], name: dog[1], breed: dog[2])
end

def update
  sql = <<-SQL
  UPDATE dogs SET name = ? WHERE id = ?;
  SQL
  DB[:conn].execute(sql, self.name, self.id)
end

def self.find_or_create_by(name:, breed:)
  dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? and breed = ?", name, breed)
  if dog.empty?
    self.create(name: name, breed: breed)
  else
  new_dog = Dog.new(id: dog[0][0], name: dog[0][1], breed: dog[0][2])
end

end
end
