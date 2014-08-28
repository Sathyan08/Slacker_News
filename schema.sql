CREATE TABLE articles (
  id serial PRIMARY KEY,
  name varchar(255) NOT NULL,
  description varchar(300) NOT NULL,
  url varchar(60) NOT NULL
);


CREATE TABLE comments (
  id serial PRIMARY KEY,
  commenter varchar(55) NOT NULL,
  contents varchar(80) NOT NULL,
  reference_article integer references articles(id),
  reference_comment integer
  );
