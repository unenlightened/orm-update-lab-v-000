require_relative "../config/environment.rb"

class Student
  attr_accessor :name, :grade
  attr_reader :id

  def initialize(name, grade, id = nil)
    @id = id
    @name = name
    @grade = grade
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade INTEGER
      )
    SQL

    DB[:conn].execute(sql)
  end

 def self.drop_table
   sql = 'DROP TABLE IF EXISTS students'
   DB[:conn].execute(sql)
 end

 def save
   if self.id
     self.update
   else
     sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
 end

 def self.create(name, grade)
   self.new(name, grade).tap {|song| song.save}
 end

 def self.new_from_db(row)
   id, name, grade = row
   self.new(name, grade, id)
 end

 def self.find_by_name(name)
   sql = <<-SQL
      SELECT *
      FROM students
      WHERE name = ?
    SQL
   self.new_from_db(DB[:conn].execute(sql,name).flatten)
 end

 def update
   sql = 'UPDATE students SET name = ?, grade = ? WHERE id = ?'
   DB[:conn].execute(sql, self.name, self.grade, self.id)
 end

end
