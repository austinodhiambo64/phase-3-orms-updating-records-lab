require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  attr_accessor :name, :grade, :id

  def initialize(name:, grade:, id: nil)
    @name = name
    @grade = grade
    @id = nil
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade INTEGER
    )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE IF EXISTS students
    SQL
    DB[:conn].execute(sql)
  end

  def save 
    if self.id
      update
    else
      sql = <<-SQL
      INSERT INTO students (name, grade)
      VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, name, grade)
      self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
      self
    end
  end

    def self.create(name:, grade:)
      student = Student.new(name: name, grade: grade)
      student.save
    end

    def self.new_from_db(row)
      self.new(id: row[0], name: row[1], grade: [2])
    end

    def self.find_by_name(name)
      sql = <<-SQL
      SELECT * FROM students WHERE name = ?
      LIMIT 1
      SQL

      row = DB[:conn].execute(sql, id).first
      self.new_from_db(row) if row
    end

    def update 
      sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
      DB[:conn].execute(sql, self.name, self.grade, self.id)
    end
end

