require_relative 'modelbase'

class Question < Modelbase
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