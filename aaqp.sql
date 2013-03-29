CREATE TABLE users (
  id INTEGER PRIMARY KEY,
fname VARCHAR(20) NOT NULL,
lname VARCHAR(20) NOT NULL,
is_instructor CHAR(1) CHECK (is_instructor IN ('T', 'F'))
);

CREATE TABLE  questions (
  id INTEGER PRIMARY KEY,
title VARCHAR(50) NOT NULL,
body TEXT NOT NULL,
author_id INTEGER NOT NULL,

FOREIGN KEY (author_id) REFERENCES users(id)
);

CREATE TABLE question_followers(
  id INTEGER PRIMARY KEY,
follower_id INTEGER NOT NULL,
question_id INTEGER NOT NULL,

FOREIGN KEY (follower_id) REFERENCES users(id),
FOREIGN KEY (question_id) REFERENCES questions(id)
);

CREATE TABLE question_replies(
  id INTEGER PRIMARY KEY,
parent_question_id INTEGER NOT NULL,
parent_reply_id INTEGER,
author_id INTEGER NOT NULL,
body TEXT NOT NULL,

FOREIGN KEY (parent_question_id) REFERENCES questions(id),
FOREIGN KEY (parent_reply_id) REFERENCES question_replies(id)
FOREIGN KEY (author_id) REFERENCES users(id)
);

CREATE TABLE question_actions(
  id INTEGER PRIMARY KEY,
type VARCHAR(10) CHECK (type IN ('redact', 'close', 'reopen')),
question_id INTEGER NOT NULL,

FOREIGN KEY (question_id) REFERENCES questions(id)
);

CREATE TABLE question_likes(
  id INTEGER PRIMARY KEY,
liker_id INTEGER NOT NULL,
question_id INTEGER NOT NULL,

FOREIGN KEY (liker_id) REFERENCES users(id),
FOREIGN KEY (question_id) REFERENCES questions(id)
);

INSERT INTO users ('fname', 'lname', 'is_instructor' )
     VALUES ('Kellen', 'Hart', 'T'), ('Dale', 'Knauss', 'F'), ('Rich', 'Wallett', 'F');

INSERT INTO questions ('title', 'body', 'author_id')
     VALUES ('Why isnt sqlite pretty?',
						"why can't i get my column headers to show in cli", 1),

						('Why is sqlite so ugly?',
						"why???", 3),

						('more than the mandated price. Legal SemiSemiSelling blue jeans purlegal legal chased from foreign tourist. Legal Illegal Illegal Sale',
						"is it his shiny hair?", 2),

						('what is round and hard?',
						"is it a sphero?", 1),

						('Why is it so warm in here?',
						"sometimes", 3)
						;

INSERT INTO question_likes('liker_id', 'question_id')
VALUES			('1', '2'), ('1', '1'), ('2', '1'), ('3', '1')
						;

INSERT INTO question_followers('follower_id', 'question_id')
VALUES			('1', '2'), ('1', '3'), ('2', '1'), ('3', '1'),
	 						('2', '3'), ('3', '3')
						;

INSERT INTO question_replies('parent_question_id', 'parent_reply_id', 'author_id',
														'body')
VALUES 			('1', NULL, '3','it does not age well'),
						('1','1','2','horse ebooks was here')
						;