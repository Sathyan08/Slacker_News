require 'sinatra'

require 'pg'

require 'sinatra/reloader'

require 'pry'


def db_connection
  begin
    connection = PG.connect(dbname: 'slacker_news')

    yield(connection)

  ensure
    connection.close
  end
end


def url_exists_in_file?(url)
  # articles = pull_articles("articles.csv")

  # articles.each do |article|
  #   if article["url"] == url
  #     return true
  #   end
  # end
    db_connection do |conn|
      @articles = conn.exec('SELECT * FROM articles WHERE url = $1;', [url])
    end

    @articles.each do |article|
      if article["url"] == url
        return true
      end
    end

  false
end



def validation_results(name, url, description)
  error_messages = []
  description_test = description.gsub(" ", "")

  if name.length == 0
    error_messages << "The name field was left blank.  Please fill in the article name."
  end

  if url.length == 0
    error_messages << "The url field was left blank.  Please fill in the url field."
  end

  if url_exists_in_file?(url) == true
    error_messages << "The url that you input is already in the article database.  You can only add articles that have not already been posted."
  end

  if description_test.length == 0
    error_messages << "The description was left blank.  Please input a description."
  end

  if description_test.length < 20
    error_messages << "The description field was less than 20 characters.  Please input a description that is twenty characters or less (not including spaces)."
  end

  error_messages
end


def validation_comments(commenter,description_comment)

  error_messages = []

  if commenter == nil || commenter.length == 0
    error_messages << "You did not fill out your name.  Please fill in your name."
  end

  if description_comment == nil || description_comment.length == 0
    error_messages << "You did not type anything in the comment field.  Please fill in the comment."
  end

  error_messages
end




############################################
#####                                 #####
#####                                 #####
############################################
get '/' do

 db_connection do |conn|
      @articles = conn.exec('SELECT * FROM articles')
    end

  erb :index

end

get '/submit' do
  @error_messages = []
  @name = ''
  @url  = ''
  @description = ''

  erb :submit
end

post '/submit' do
  name = params["article_name"]
  url = params["article_url"]
  description = params["article_description"]
  error_messages = []
  error_messages = validation_results(name, url, description)

  if error_messages.length == 0
    db_connection do |conn|
      conn.exec('INSERT INTO articles (name, url, description) VALUES ($1, $2, $3);', [name, url, description])
    end

    redirect '/'

  else
    @name = name
    @url  = url
    @description = description
    @error_messages = error_messages

    erb :submit
  end


end

get '/comments/:id' do

  @id = params[:id]
  @commenter = ''
  @description = ''
  @error_messages = []

  db_connection do |conn|
      @article = conn.exec('SELECT * FROM articles WHERE id = $1', [@id])
      @comments = conn.exec('SELECT * FROM comments')

  end

  erb :comments
end

post '/comments/:id' do
  commenter = params["commenter"]
  description_comment = params["description_comment"]
  error_messages = validation_comments(commenter,description_comment)
  @id = params[:id]


  if error_messages == nil || error_messages.length == 0
    db_connection do |conn|
      conn.exec('INSERT INTO comments (commenter, contents, reference_article) VALUES ($1, $2, $3);', [commenter, description_comment, @id.to_i])
    end

  else
    @commenter = commenter
    @description_comment = description_comment
    @error_messages = error_messages


    db_connection do |conn|
      @article = conn.exec('SELECT * FROM articles WHERE id = $1', [@id])
      @comments = conn.exec('SELECT * FROM comments')
    end

    redirect '/'
  end


end









