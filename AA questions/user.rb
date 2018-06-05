class User 
  attr_accessor :fname, :lname, :id
  def self.find_by_name(fname, lname)
    data = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT *
      FROM users
      WHERE fname = ? AND lname = ?
    SQL
    User.new(data.first)
  end
  
  def self.find_by_user_id(user_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT *
      FROM users
      WHERE id = ?
    SQL
    
    User.new(data.first)
  end
  
  def initialize(options)
    @id= options["id"]
    @fname= options["fname"]
    @lname= options["lname"]
  end
  
  def authored_questions
    Question.find_by_author_id(self.id)
  end  
  
  def authored_replies
    Reply.find_by_user_id(self.id)
  end  
  
  def followed_questions
    QuestionFollow.followed_questions_for_user_id(self.id)
  end
  
  def liked_questions
    QuestionLikes.liked_questions_for_user_id(self.id)
  end
  
  def average_karma
    likes = QuestionsDatabase.instance.execute(<<-SQL, self.id)
      SELECT (CAST(COUNT(question_likes.id) AS FLOAT)/ COUNT(DISTINCT (questions.id))) AS Karma
      FROM users
      JOIN question_likes ON users.id = question_likes.user_id
      LEFT JOIN questions ON questions.id = question_likes.question_id
      WHERE questions.user_id = ?
      GROUP BY questions.user_id
    SQL
    
    likes.first["Karma"]
  end  
  
  def save
    if @id 
      update
    else 
      create
    end  
  end
  
  def create
    QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname)
      INSERT INTO 
        users (fname, lname)
      VALUES 
        ( ?, ?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end  
  
  def update
    QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname, @id)
      UPDATE 
        users
      SET
        fname = ?, lname = ?
      WHERE 
        id = ?
    SQL
  end  
  
end