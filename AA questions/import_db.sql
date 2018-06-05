DROP TABLE if EXISTS users;
DROP TABLE if EXISTS questions;
DROP TABLE if EXISTS question_follows;
DROP TABLE if EXISTS replies;
DROP TABLE if EXISTS question_likes;

CREATE TABLE users(
  id INTEGER PRIMARY KEY,
  fname VARCHAR(100) NOT NULL,
  lname VARCHAR(100) NOT NULL
);

CREATE TABLE questions(
  id INTEGER PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  body TEXT NOT NULL,
  user_id INTEGER NOT NULL,
  
  FOREIGN KEY (user_id) REFERENCES users(id)
  
);

CREATE TABLE question_follows(
  id INTEGER PRIMARY KEY,
  
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE replies(
  id INTEGER PRIMARY KEY,
  
  question_id INTEGER NOT NULL,
  parent_id INTEGER,
  user_id INTEGER NOT NULL,
  body TEXT NOT NULL,
  
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (parent_id) REFERENCES replies(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE question_likes(
  id INTEGER PRIMARY KEY,
  
  question_id INTEGER NOT NULL,
  
  user_id INTEGER NOT NULL,
  
  num_likes INTEGER DEFAULT 0,
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

INSERT INTO 
  users (fname, lname)
VALUES 
  ('a','b'),
  ('c','d'),
  ('e','f');
  
INSERT INTO 
  questions (title, body, user_id)
VALUES 
  ('Who','abc', (SELECT id FROM users WHERE fname = 'a' AND lname = 'b')),
  ('What','efg', (SELECT id FROM users WHERE fname = 'a' AND lname = 'b')),
  ('When','hij', (SELECT id FROM users WHERE fname = 'c' AND lname = 'd')),
  ('Where','klm', (SELECT id FROM users WHERE fname = 'c' AND lname = 'd')),
  ('Why','nop', (SELECT id FROM users WHERE fname = 'e' AND lname = 'f'));
  
INSERT INTO 
  question_follows (question_id, user_id)
VALUES 
  ((SELECT id FROM questions WHERE id = 4),
  (SELECT id FROM users WHERE fname = 'a' AND lname = 'b')),
  
  ((SELECT id FROM questions WHERE id = 1),
   (SELECT id FROM users WHERE fname = 'e' AND lname = 'f')),
   
 ((SELECT id FROM questions WHERE id = 2),
  (SELECT id FROM users WHERE fname = 'c' AND lname = 'd')),
   
  ((SELECT id FROM questions WHERE id = 2),
   (SELECT id FROM users WHERE fname = 'e' AND lname = 'f')),
   
  ((SELECT id FROM questions WHERE id = 5),
   (SELECT id FROM users WHERE fname = 'c' AND lname = 'd'));
   
   
INSERT INTO
  replies (question_id, parent_id, user_id, body)
VALUES
  ((SELECT id FROM questions WHERE id = 4), 
  NULL, 
  (SELECT id FROM users WHERE fname = 'a' AND lname = 'b'), 
  'derpderpderp'),

  ((SELECT id FROM questions WHERE id = 5), 
  NULL, 
  (SELECT id FROM users WHERE fname = 'c' AND lname = 'd'), 
  'terpterpterp');
  
INSERT INTO
  replies (question_id, parent_id, user_id, body)
VALUES
  ((SELECT id FROM questions WHERE id = 4), 
  (SELECT id FROM replies WHERE id = 1 ), 
  (SELECT id FROM users WHERE fname = 'c' AND lname = 'd'), 
  'herpherpherp'),
  
  ((SELECT id FROM questions WHERE id = 4), 
  (SELECT id FROM replies WHERE id = 1 ), 
  (SELECT id FROM users WHERE fname = 'e' AND lname = 'f'), 
  'dingdong');
  
INSERT INTO
  replies (question_id, parent_id, user_id, body)
VALUES
  ((SELECT id FROM questions WHERE id = 4), 
  (SELECT id FROM replies WHERE id = 3 ), 
  (SELECT id FROM users WHERE fname = 'a' AND lname = 'b'), 
  'lalalalalalala');
  
INSERT INTO
  question_likes (question_id, user_id)
VALUES
  ((SELECT id FROM questions WHERE id = 4),  
  (SELECT id FROM users WHERE fname = 'a' AND lname = 'b')),
  
  ((SELECT id FROM questions WHERE id = 4),  
  (SELECT id FROM users WHERE fname = 'e' AND lname = 'f')),
  
  ((SELECT id FROM questions WHERE id = 5),  
  (SELECT id FROM users WHERE fname = 'c' AND lname = 'd')),
  
  ((SELECT id FROM questions WHERE id = 3),  
  (SELECT id FROM users WHERE fname = 'a' AND lname = 'b'));
    
