class Question < AAQPModel
  def self.asking_student(question_id)
    query = <<-SQL
    SELECT users.id, users.fname, users.lname, users.is_instructor
    FROM users JOIN questions ON users.id = questions.author_id
    WHERE questions.id = ?
    SQL

    AAQPDatabase.instance.execute(query, question_id)
  end

  def self.find(id)
    query = <<-SQL
    SELECT *
    FROM questions
    WHERE questions.id = ?
    SQL

    result_hash = AAQPDatabase.instance.execute(query, id)
    Question.new(result_hash[0])
  end

  def self.most_liked(n)
    query = <<-SQL
    SELECT questions.id, questions.title, questions.body, questions.author_id
    FROM questions JOIN question_likes ON questions.id = question_likes.question_id
    GROUP BY questions.id
    ORDER BY COUNT(question_likes.question_id) DESC
    LIMIT ?
    SQL #REV: cool! i didn't know aobut the limit thing.

    result_array = AAQPDatabase.instance.execute(query, n)
    Question.make_instances(result_array)
  end

  def self.most_followed(n)
    query = <<-SQL
    SELECT questions.id, questions.title, questions.body, questions.author_id
    FROM questions JOIN question_followers ON questions.id = question_followers.question_id
    GROUP BY questions.id
    ORDER BY COUNT(question_followers.question_id) DESC
    LIMIT ?
    SQL

    result_array = AAQPDatabase.instance.execute(query, n)
    Question.make_instances(result_array) #REV: I see how you do this, but you might consider mapping
    #REV: the result array to an array of Question.new()'s.
  end

  attr_accessor :title, :body, :author_id
  attr_reader :id

  def initialize(hash)
    @title = hash["title"]
    @body = hash["body"]
    @author_id = hash["author_id"]
    @id = hash["id"]
  end

  def save #REV: i may split up this into an insert and update method, and then have save call them from the if statement.
    if self.id.nil?
      insert = <<-SQL
      INSERT INTO questions ('title', 'body', 'author_id')
      VALUES (:title, :body, :author_id)
      SQL

      insert_response = AAQPDatabase.instance.execute(insert,
          {title: self.title,
            body: self.body,
            author_id: self.author_id})
    else
      update = <<-SQL
      UPDATE questions
        SET title = :title, body = :body, author_id = :author_id
        WHERE questions.id = :id
      SQL

      update_response = AAQPDatabase.instance.execute(update,
          {title: self.title,
            body: self.body,
            author_id: self.author_id,
            id: self.id })
    end
  end

  def num_likes
    query = <<-SQL
    SELECT COUNT(*)
    FROM users JOIN question_likes ON users.id = question_likes.liker_id
    JOIN questions ON question_likes.question_id = questions.id
    WHERE questions.id = ?
    GROUP BY questions.id
    SQL

    results_array = AAQPDatabase.instance.execute(query, self.id)
    results_array[0]['COUNT(*)']
  end

  def followers
    query = <<-SQL
    SELECT users.id, users.fname, users.lname, users.is_instructor
    FROM questions JOIN question_followers
      ON questions.id = question_followers.question_id
      JOIN users ON question_followers.follower_id = users.id
    WHERE questions.id = ?
    GROUP BY users.id
    SQL

    results_array = AAQPDatabase.instance.execute(query, self.id)
    User.make_instances(results_array)
  end

  def replies
    query = <<-SQL
    SELECT question_replies.id, question_replies.body, question_replies.author_id,
      question_replies.parent_question_id, question_replies.parent_question_id
    FROM questions JOIN question_replies
      ON questions.id = question_replies.parent_question_id
    WHERE questions.id = ?
    SQL

    results_array = AAQPDatabase.instance.execute(query, self.id)
    QuestionReply.make_instances(results_array)
  end
end
