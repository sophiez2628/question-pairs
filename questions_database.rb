require 'singleton'
require 'sqlite3'

class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.results_as_hash = true
    self.type_translation = true
  end
end

class User
  attr_accessor :id, :fname, :lname

  def initialize(attributes = {})
    @id, @fname, @lname = attributes.values_at('id', 'fname', 'lname')
  end

  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        users.id = ?
    SQL

    User.new(data.first)
  end

  def self.find_by_name(fname, lname)
    data = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        users.fname = ? AND users.lname = ?
    SQL

    User.new(data.first)
  end

  def authored_questions
    Question.find_by_user_id(@id)
  end

  def authored_replies
    Reply.find_by_user_id(@id)
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(@id)
  end
end

class Question
  attr_accessor :id, :title, :body, :user_id

  def initialize(attributes = {})
    @id, @title, @body, @user_id = attributes.values_at('id', 'title', 'body', 'user_id')
  end

  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        questions.id = ?
    SQL

    raise "Multiple questions found!" if data.length > 1
    Question.new(data.first)
  end

  def self.find_by_title(title)
    data = QuestionsDatabase.instance.execute(<<-SQL, title)
      SELECT
        *
      FROM
        questions
      WHERE
        questions.title = ?
    SQL

    Question.new(data.first)
  end

  def self.find_by_user_id(user_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        questions
      WHERE
        questions.user_id = ?
    SQL

    questions.map do |question|
      Question.new(question)
    end
  end

  def author
    User.find_by_id(@user_id)
  end

  def replies
    Reply.find_by_question_id(@id)
  end

  def followers
    QuestionFollow.followers_for_question_id(@id)
  end
end

class QuestionFollow
  attr_accessor :id, :question_id, :follower_id

  def initialize(attributes = {})
    @id, @question_id, @follower_id = attributes.values_at('id', 'question_id', 'follower_id')
  end

  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_follows
      WHERE
        question_follows.id = ?
    SQL

    Question.new(data.first)
  end

  def self.followers_for_question_id(question_id)
    users = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        users.* -- fname, lname
      FROM
        question_follows
      JOIN
        users
      ON
        question_follows.follower_id = users.id
      WHERE
        question_follows.question_id = ?
    SQL

    users.map do |user_hash|
      User.new(user_hash) # User.find_by_name(user_hash['fname'], user_hash['lname'])
    end
  end

  def self.followed_questions_for_user_id(user_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        questions.*
      FROM
        question_follows
      JOIN
        questions ON question_follows.question_id = questions.id
      WHERE
        question_follows.follower_id = ?
    SQL

    questions.map do |question_hash|
      Question.new(question_hash)
    end
  end

  def self.most_followed_questions(n)
    questions = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        questions.* -- fname, lname
      FROM
        question_follows
      JOIN
        questions
      ON
        question_follows.question_id = questions.id
      GROUP BY
        question_id
      -- HAVING
      --   COUNT(follower_id)
      ORDER BY
        COUNT(follower_id) DESC
      LIMIT
        ?
    SQL

    questions.map do |question_hash|
      Question.new(question_hash) # User.find_by_name(user_hash['fname'], user_hash['lname'])
    end

  end
end

class Reply
  attr_accessor :id, :question_id, :reply_id, :user_id, :body

  def initialize(attributes = {})
    @id, @question_id, @reply_id, @user_id, @body =
      attributes.values_at('id', 'question_id', 'reply_id', 'user_id', 'body')
  end

  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        replies.id = ?
    SQL

    Reply.new(data.first)
  end

  def self.find_by_user_id(user_id)
    replies = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        replies.user_id = ?
    SQL

    replies.map do |reply|
      Reply.new(reply)
    end
  end

  def self.find_by_question_id(question_id)
    replies = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        replies.question_id = ?
    SQL

    replies.map do |reply|
      Reply.new(reply)
    end
  end

  def author
    User.find_by_id(@user_id)
  end

  def question
    Question.find_by_id(@question_id)
  end

  def parent_reply
    Reply.find_by_id(@reply_id)
  end

  def child_replies
    replies = QuestionsDatabase.instance.execute(<<-SQL, @id)
      SELECT
        *
      FROM
        replies
      WHERE
        replies.reply_id = ?
    SQL

    replies.map do |reply|
      Reply.new(reply)
    end
  end
end

class QuestionLike
  def initialize(attributes = {})
    @id, @question_id, @user_id = attributes.values_at('id', 'question_id', 'user_id')
  end

  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_likes
      WHERE
        question_likes.id = ?
    SQL

    QuestionLike.new(data.first)
  end
end
