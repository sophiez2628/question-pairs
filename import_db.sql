DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL
);

DROP TABLE IF EXISTS questions;
CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  body TEXT NOT NULL,
  user_id INTEGER NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS question_follows;
CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  follower_id INTEGER NOT NULL,
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (follower_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS replies;
CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  reply_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (reply_id) REFERENCES replies(id),
  FOREIGN KEY (user_id) REFERENCES users(id),
  body TEXT NOT NULL
);

DROP TABLE IF EXISTS question_likes;
CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  FOREIGN KEY (question_id) REFERENCES question(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);


-- Seed out database
INSERT INTO
  users (fname, lname)
VALUES
  ('Patrick', 'Sandquist'), ('Sophie','Zhao');

INSERT INTO
  questions (title, body, user_id)
VALUES
  ('color', 'what is my favorite color?', (SELECT id FROM users WHERE fname = 'Patrick')),
  ('food', 'can lunch break be longer?', (SELECT id FROM users WHERE fname = 'Patrick')),
  ('bonus', 'do we have a bonus project today?', (SELECT id FROM users WHERE fname = 'Sophie')),
  ('homework', 'when is homework due?', (SELECT id FROM users WHERE fname = 'Sophie'));

INSERT INTO
  question_follows (question_id, follower_id)
VALUES
  ((SELECT id FROM questions WHERE title = 'color'),(SElECT id FROM users WHERE fname = 'Sophie')),
  ((SELECT id FROM questions WHERE title = 'bonus'),(SElECT id FROM users WHERE fname = 'Patrick'));

INSERT INTO
  replies (question_id, reply_id, user_id, body)
VALUES
  ((SELECT id FROM questions WHERE title = 'bonus'), NULL, (SElECT id FROM users WHERE fname = 'Patrick'),'Yes!');

INSERT INTO
  question_likes (question_id, user_id)
VALUES
  ((SELECT id FROM questions WHERE title = 'bonus'), (SElECT id FROM users WHERE fname = 'Patrick'));
