
class Tags
  # def self.most_popular
    # query = <<-SQL
    # SELECT COUNT(*)
    # FROM tags JOIN question_tags ON tags.id = question_tags.tag_id
    # JOIN questions ON question_tags.question_id = questions.id
    # GROUP BY tags.id
    # ORDER BY COUNT(*) ASC
    # LIMIT 1
    # SQL
    #
    # AAQPDatabase.instance.execute(query, question_id)

    def self.most_popular
      result_array = []
      ['html', 'css', 'ruby', 'javascript'].each do |tag|

        query = <<-SQL
        SELECT questions.id, questions.title, questions.body, questions.author_id
        FROM questions
        JOIN question_likes
        ON questions.id = question_likes.question_id
        JOIN question_tags
        ON  questions.id = question_tags.question_id
        JOIN tags
        ON question_tags.tag_id = tags.id
        WHERE tags.name = ?
        GROUP BY questions.id
        ORDER BY COUNT(question_likes.question_id) DESC
        LIMIT 5
        SQL
        #debugger
        p result_array += AAQPDatabase.instance.execute(query, tag)
      end
      Question.make_instances(result_array)
    end


  attr_accessor :name
  attr_reader :id

  def initialize(hash)
    @name = hash["name"]
    @id = hash["id"]
  end


end