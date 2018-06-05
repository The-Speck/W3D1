
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