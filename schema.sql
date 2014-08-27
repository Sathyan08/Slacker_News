CREATE TABLE articles (
  id serial PRIMARY KEY,
  name varchar(255),
  description varchar(300),
  url varchar(60)
);


CREATE TABLE comments (
  id serial PRIMARY KEY,
  commenter varchar(55),
  contents varchar(80)
  );
