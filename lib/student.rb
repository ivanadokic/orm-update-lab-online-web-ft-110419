require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  attr_accessor :id, :name, :grade
  def initialize(id=nil, name, grade)
    @id, @name, @grade = id, name, grade
  end

  def self.create_table
    #creates the students table in the database
    sql = <<-SQL 
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT, 
        grade TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table 
    #drops the students table from the database
    DB[:conn].execute("DROP TABLE IF EXISTS students")
  end

  def save
    #saves an instance of the Student class to the database and then sets the given students `id` attribute
    if self.id
      self.update
    else
      sql = <<-SQL 
        INSERT INTO students (name, grade)
        VALUES (?,?)
      SQL

      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def self.create(name="Sally", grade="10th")
    student = Student.new(name, grade)
    student.save
    student
  end

  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    grade = row[2]
    self.new(id, name, grade)
  end 

  def self.find_by_name(name)
    sql = "SELECT * FROM students WHERE name = ?"
    DB[:conn].execute(sql, name).map { |row| new_from_db(row) }.first
  end

  def update
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end
end
