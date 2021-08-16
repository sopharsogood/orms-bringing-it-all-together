require_relative '../config/environment.rb'

class Dog
    attr_accessor :name, :breed
    attr_reader :id

    def initialize(name:, breed:, id: nil)
        self.name = name
        self.breed = breed
        @id = id
    end

    def self.create_table
        sql = "CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        )"

        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = "DROP TABLE IF EXISTS dogs"

        DB[:conn].execute(sql)
    end

    def save
        sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def self.new_from_db(row)
        Dog.new(name: row[1], breed: row[2], id: row[0])
    end

    def self.create(attributes)
        dog = Dog.new(name: attributes[:name], breed: attributes[:breed])
        dog.save
        dog
    end

    def self.find_by_id(id)
        sql = "SELECT * FROM dogs WHERE id = ? LIMIT 1"
        DB[:conn].execute(sql, id).collect do |row|
            self.new_from_db(row)
        end.first
    end

    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name = ? LIMIT 1"
        DB[:conn].execute(sql, name).collect do |row|
            self.new_from_db(row)
        end.first
    end

    def self.find_or_create_by(name:, breed:)
        sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
        dog_select = DB[:conn].execute(sql, name, breed)
        if dog_select.empty?
            dog = self.create({:name => name, :breed => breed})
        else
            dog_data = dog_select[0]
            dog = self.new(name: dog_data[1], breed: dog_data[2], id: dog_data[0])
        end
        dog
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

end
