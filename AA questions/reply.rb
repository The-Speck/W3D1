class Reply 
  attr_reader :user_id, :parent_id 
  attr_accessor :id
  
  def self.find_by_user_id(user_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT *
      FROM replies
      WHERE user_id = ?
    SQL
    data.map { |datum| Reply.new(datum) }
  end
  
  def save
    if @id 
      update
    else 
      create
    end  
  end
  
  def create
    QuestionsDatabase.instance.execute(<<-SQL, @question_id, @parent_id, @user_id, @body)
      INSERT INTO 
        replies (question_id, parent_id, user_id, body)
      VALUES 
        ( ?, ?, ?, ?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end  
  
  def update
    QuestionsDatabase.instance.execute(<<-SQL, @question_id, @parent_id, @user_id, @body, @id)
      UPDATE 
        replies
      SET
        question_id = ?, parent_id = ?, user_id = ?, body = ?
      WHERE 
        id = ?
    SQL
  end  
  
  def self.find_by_question_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT *
      FROM replies
      WHERE question_id = ?
    SQL
    data.map { |datum| Reply.new(datum) }
  end
  
  def initialize(options)
    @id = options["id"]
    @question_id = options["question_id"]
    @parent_id = options["parent_id"]
    @user_id = options["user_id"]
    @body = options["body"]
  end  
  
  def author
    User.find_by_user_id(self.user_id)
  end
  
  def question
    data = QuestionsDatabase.instance.execute(<<-SQL, self.question_id)
      SELECT *
      FROM questions
      WHERE id = ?
    SQL
    
    Question.new(data.first)
  end
  
  def parent_reply
    data = QuestionsDatabase.instance.execute(<<-SQL, self.parent_id)
      SELECT *
      FROM replies
      WHERE id = ?
    SQL
    Reply.new(data.first)
  end
  
  def child_replies
    data = QuestionsDatabase.instance.execute(<<-SQL, self.id)
      SELECT *
      FROM replies
      WHERE parent_id = ?
    SQL
    data.map{ |datum| Reply.new(datum) }
  end
end
