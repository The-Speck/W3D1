require 'byebug'
class Modelbase 
  
  NAME_HASH = {
    'User' => 'users',
    'Question' => 'questions',
    'Reply' => 'replies',
    'QuestionFollow' => 'question_follows',
    'QuestionLikes' => 'question_likes'
  }
  
  def self.find_by_id(id)
    table = NAME_HASH[to_s]
    # debugger
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT *
      FROM #{table}
      WHERE id = ?
    SQL
  
    self.new(data.first)
  end
  
  def save
    if @id 
      update
    else 
      create
    end  
  end
  
  def create
    p table = NAME_HASH[self.class.to_s]
    p var = instance_variables.drop(1)
    
    p i_arr = var.map(&:to_s).join(", ")
    p q_arr = questions(var.count)
    p v_arr = "(#{var_names(var)})"
    
    
    QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname)
      INSERT INTO 
        #{table} #{v_arr}
      VALUES 
        (#{q_arr})
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end  
  
  def var_names(var_arr)
    arr = []
    var_arr.map(&:to_s).each { |var| arr << var[1..-1] }
    arr.join(", ")
  end
  
  def questions(n)
    arr = []
    n.times {arr << "?"}
    arr.join(", ")
  end
  
  def update
    table = NAME_HASH[to_s]
    
    QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname, @id)
      UPDATE 
        #{table}
      SET
        fname = ?, lname = ?
      WHERE 
        id = ?
    SQL
  end  
  
end  