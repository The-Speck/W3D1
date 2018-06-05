require 'sqlite3'
require 'singleton'

class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize
      super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end
  
#===================================================================================

class Question
  attr_reader :id, :user_id
  def self.find_by_author_id(author_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, author_id)
      SELECT *
      FROM questions
      WHERE user_id = ?
    SQL
    
    data.map { |datum| Question.new(datum) }
  end    
  
  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
  end  
  
  def initialize(options)
    @id = options["id"]
    @title = options["title"]
    @body = options["body"]
    @user_id= options["user_id"]
  end  
  
  def save
    if @id 
      update
    else 
      create
    end  
  end
  
  def create
    QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @user_id)
      INSERT INTO 
        questions (title, body, user_id)
      VALUES 
        (?, ?, ?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end  
  
  def update
    QuestionsDatabase.instance.execute(<<-SQL, @body, @id)
      UPDATE 
        questions
      SET
        body = ?
      WHERE 
        id = ?
    SQL
  end  
  
  def author 
    data = QuestionsDatabase.instance.execute(<<-SQL, self.user_id)
      SELECT *
      FROM users
      WHERE id = ?
    SQL
    User.new(data.first)
  end  
  
  def replies
    Reply.find_by_question_id(self.id)
  end
  
  def followers
    QuestionFollow.followers_for_question_id(self.id)
  end
  
  def likers
    QuestionLikes.likers_for_question_id(self.id)
  end
  
  def num_likes
    QuestionLikes.num_likes_for_question_id(self.id)
  end
  
  def self.most_liked(n)
    QuestionLikes.most_liked_questions(n)
  end  
end 

#===================================================================================

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

#===================================================================================

class QuestionFollow 
  def self.followers_for_question_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT *
    FROM question_follows
    JOIN users ON users.id = question_follows.user_id
    WHERE question_follows.question_id = ?
    SQL
    data.map { |datum| User.new(datum) }
  end  
  
  def self.followed_questions_for_user_id(user_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
    SELECT *
    FROM question_follows
    JOIN questions ON questions.id = question_follows.question_id
    WHERE question_follows.user_id = ?
    SQL
    data.map { |datum| Question.new(datum) }
  end  
  
  def self.most_followed_questions(n)
    data = QuestionsDatabase.instance.execute(<<-SQL, n)
    SELECT *
    FROM question_follows
    JOIN questions ON questions.id = question_follows.question_id
    GROUP BY question_follows.question_id
    ORDER BY COUNT(question_follows.user_id) DESC
    LIMIT ?
    SQL
    
    data.map { |datum| Question.new(datum) }
  end
  
  def initialize(options)
    @id= options["id"]
    @question_id= options["question_id"]
    @user_id= options["user_id"]
  end 
end   

#=================================================================================== 

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

#===================================================================================

class QuestionLikes
  def initialize(options)
    @id = options["id"]
    @question_id = options["question_id"]
    @user_id = options["user_id"]
  end  
  
  def self.likers_for_question_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT user_id
      FROM question_likes
      WHERE question_id = ?
    SQL
    
    data.map{ |datum| User.find_by_user_id(datum["user_id"])}
  end  
  
  def self.num_likes_for_question_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT COUNT(user_id) AS num_likes
      FROM question_likes
      WHERE question_id = ?
      GROUP BY question_id
    SQL
    
    data.first["num_likes"]
  end  
  
  def self.liked_questions_for_user_id(user_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT *
      FROM question_likes
      JOIN questions ON questions.id = question_likes.question_id
      WHERE question_likes.user_id = ?
    SQL
    
    data.map{ |datum| Question.new(datum) }
  end
  
  def self.most_liked_questions(n)
    data = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT *
      FROM question_likes
      JOIN questions ON questions.id = question_likes.question_id
      GROUP BY question_likes.question_id
      ORDER BY COUNT(question_likes.user_id) DESC
      LIMIT ?
    SQL
    
    data.map{ |datum| Question.new(datum) }
  end
  
end  

  
  