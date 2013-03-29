class User < AAQPModel
  def self.find_by_name(fname, lname)
    query = <<-SQL
    SELECT *
    FROM users
    WHERE fname = ? AND lname = ?
    SQL

    result_array = AAQPDatabase.instance.execute(query, fname, lname)
    User.new(result_array[0])
  end

  def save
    if self.id.nil?
      insert = <<-SQL
      INSERT INTO users ('fname', 'lname', 'is_instructor' )
      VALUES (:fname, :lname, :is_instructor)
      SQL

      insert_response = AAQPDatabase.instance.execute(insert,
          {fname: self.fname,
            lname: self.lname,
            is_instructor: self.is_instructor})
    else
      update = <<-SQL
      UPDATE users
        SET fname = :fname, lname = :lname, is_instructor = :is_instructor
        WHERE users.id = :id
      SQL

      update_response = AAQPDatabase.instance.execute(update,
          {fname: self.fname,
            lname: self.lname,
            is_instructor: self.is_instructor,
            id: self.id })
    end
  end

  def self.asked_questions(user_name)
    fname, lname = user_name.split

    query = <<-SQL
    SELECT questions.id, questions.title, questions.body, questions.author_id
    FROM users JOIN questions ON users.id = questions.author_id
    WHERE fname = ? AND lname = ?
    SQL

    AAQPDatabase.instance.execute(query, fname, lname)
  end


  attr_accessor :fname, :lname, :is_instructor
  attr_reader :id

  def initialize(user_hash)
    @id, @fname, @lname, @is_instructor = user_hash["id"], user_hash["fname"],
                                user_hash["lname"], user_hash["is_instructor"]
  end

  def average_karma
    query = <<-SQL
    SELECT (
      (SELECT COUNT(*)*1.0
      FROM question_likes JOIN questions
      ON question_likes.question_id = questions.id
      JOIN users as author ON questions.author_id = author.id
      WHERE author.id = :second_id
      GROUP BY author.id)
      /
      (SELECT COUNT(*)
      FROM users AS uq
      JOIN questions AS qq
      ON uq.id = qq.author_id
      WHERE uq.id = :first_id
      GROUP BY uq.id)
    )  AS average
    SQL

    results_array = AAQPDatabase.instance.execute(query,
                    {first_id: self.id, second_id: self.id } )
    p results_array[0]['average']
  end


  def questions
    query = <<-SQL
      SELECT questions.id, questions.title, questions.body, questions.author_id
      FROM users
      JOIN questions
      ON users.id = questions.author_id
      WHERE users.id = ?
    SQL
    results_array = AAQPDatabase.instance.execute(query, self.id)
    Question.make_instances(results_array)
  end

  def replies
    query = <<-SQL
      SELECT rep.id, rep.parent_question_id, rep.parent_reply_id, rep.body
      FROM users
      JOIN question_replies AS rep
      ON users.id = rep.author_id
      WHERE users.id = ?
    SQL
    results_array = AAQPDatabase.instance.execute(query, self.id)
    QuestionReply.make_instances(results_array)
  end

end
