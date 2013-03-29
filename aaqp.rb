require 'debugger' #REV: great job guys! sorry if my comments sound rude...
require 'sqlite3'
require 'singleton'
require './aaqp_model'
require './model_reply'
require './model_question'
require './model_user'
require './tags'


class AAQPDatabase < SQLite3::Database
  include Singleton

  def initialize
    super("aaqp.sqlite3")

    self.results_as_hash = true
    self.type_translation = true
  end
end



# user = User.find_by_name('Kellen', 'Hart')
# user2 = User.find_by_name('Rich', 'Wallett')
# puts "User#average_karma: #{user.average_karma}"
# puts "User#questions: #{user.questions}"
# puts "User#replies: #{user2.replies}"

# insert_user = User.new({
#   "fname" => "Kim",
#   "lname" => "Un",
#   "is_instructor" => "T"
# })
# p insert_user
# p "Insertion query result"
# p insert_user.save
# p "new user is there?"
# saved_user = User.find_by_name('Kim', 'Un')
# saved_user.lname = 'Il'
# saved_user.save
#
# p updated_user = User.find_by_name('Kim', 'Il')
# p User.asked_questions('Rich Wallett')
# p Question.asking_student(2)
#q = Question.find("1")
#p q.num_likes
# p Question.most_liked(2)
# p q.followers
#a = QuestionReply.find("1")
#p q.replies
#p Question.most_followed(2)
#p q.replies
# r = QuestionReply.new({'body' => 'You wear them on your hands, they are for clapping',
#                     'author_id' => '3',
#                     'parent_question_id' => '6',
#                     'parent_reply_id' => nil })
# r.save
# q = Question.find("6")
# p q.replies
Tags.most_popular
