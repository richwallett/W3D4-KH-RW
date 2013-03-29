class QuestionReply < AAQPModel
  attr_accessor :parent_question_id, :body, :parent_reply_id, :author_id
  attr_reader :id

  def initialize(hash)
    @id = hash["id"]
    @parent_question_id = hash["parent_question_id"]
    @parent_reply_id = hash["parent_reply_id"]
    @author_id = hash["author_id"]
    @body = hash["body"]
  end

  def replies
    query = <<-SQL
    SELECT child.id, child.body, child.parent_reply_id, child.parent_question_id
    FROM question_replies AS parent JOIN question_replies AS child
      ON parent.id = child.parent_reply_id
    WHERE child.parent_reply_id = ?
    SQL

    results_array = AAQPDatabase.instance.execute(query, self.id)
    QuestionReply.make_instances(results_array)
  end

  def self.find(id) # REV convention says to put class methods at the top
    query = <<-SQL
    SELECT *
    FROM question_replies
    WHERE question_replies.id = ?
    SQL

    result_hash = AAQPDatabase.instance.execute(query, id)
    QuestionReply.new(result_hash[0])

  end

  def save
    if self.id.nil?
      insert = <<-SQL
      INSERT INTO question_replies ('parent_question_id', 'body', 'author_id', 'parent_reply_id')
      VALUES (:parent_question_id, :body, :author_id, :parent_reply_id)
      SQL

      insert_response = AAQPDatabase.instance.execute(insert,
          {parent_question_id: self.parent_question_id,
            body: self.body,
            author_id: self.author_id,
            parent_reply_id: self.parent_reply_id})
    else
      update = <<-SQL
      UPDATE question_replies
        SET parent_question_id = :parent_question_id, body = :body, author_id = :author_id,
            parent_reply_id = :parent_reply_id
        WHERE question_replies.id = :id
      SQL

      update_response = AAQPDatabase.instance.execute(update,
          {parent_question_id: self.parent_question_id,
            body: self.body,
            author_id: self.author_id,
            parent_reply_id: self.parent_reply_id,
            id: self.id })
    end
  end

end
