require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db 
	@db = SQLite3::Database.new 'blog.db'
	@db.results_as_hash = true
end

$cur_us = 0
$active = 0
$name_user = ""

before do 

	@current_user = $cur_us
	@active = $active

	init_db

end

configure do 

	init_db

	@db.execute 'CREATE TABLE IF NOT EXISTS Users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT UNIQUE,
  password_hash TEXT,
  is_admin BOOLEAN DEFAULT 0,
  created_at DATE
)'

	@db.execute 'CREATE TABLE IF NOT EXISTS "Posts" (
	"post_id" INTEGER PRIMARY KEY AUTOINCREMENT,
	"created_date" DATE,
	"content" TEXT,
	"head" TEXT,
	"image_path" TEXT

	)'

	@db.execute 'CREATE TABLE IF NOT EXISTS "Comment" (
	"id_comment" INTEGER PRIMARY KEY AUTOINCREMENT,
	"created_date" DATE, 
	"comment" TEXT, 
	"post_id" INTEGER,
	"name_user" TEXT);'

end

get '/' do 

	@result = @db.execute 'SELECT * FROM Posts ORDER BY post_id DESC'

	erb :index

end

get '/authorization' do 

	erb :authorization

end

post '/authorization' do 

	login = params[:login].to_s.strip
	password = params[:password].to_s.strip

  if login.empty? || password.empty?
    @error = "Не все поля заполненны"
  	return erb :authorization
  end

	 # Ищем пользователя
  user = @db.execute('SELECT * FROM Users WHERE username = ?', login).first

  if user && user['password_hash'] == password
  			$cur_us = user['is_admin']
  			$active = 1
  			$name_user = user['username']

  	    redirect '/'
  elsif 
  	@error = "Неверный логин или пароль"
    erb :authorization
  end
  	
end

get '/registr' do 

 erb :registr

end

post '/registr' do 

	login = params[:login].to_s.strip
	password = params[:password].to_s.strip
	password_to = params[:password_to].to_s.strip

	if login.empty? || password.empty?
    @error = "Не все поля заполненны"
  	return erb :registr
  end

  if password != password_to 
  	@error = "Пароли не совпадают"
  	return erb :registr
  end

  user = @db.execute('SELECT * FROM Users WHERE username = ?', login).first


  existing_user = @db.execute('SELECT 1 FROM Users WHERE username = ?', login).first
  if existing_user
    @error = "Пользователь с таким логином уже существует"
    return erb :registr
  end
  	

  @db.execute 'INSERT INTO Users (username, password_hash, created_at) VALUES (?, ?, datetime())', [login, password]

  redirect to '/authorization'

end

get '/exit' do 

	$cur_us = 0
	$active = 0
	$name_user = ""

	redirect to '/'

end

get '/new' do 

	if $active != 1 
		redirect to '/'
	else

		erb :new

	end

end

post '/new' do

	head = params[:head]
	content = params[:content]
	# image = params[:image]


	if head.length <= 0
		@error = "А заголовок то пусто!"
		return erb :new
	end

	if content.length <= 0 
		@error = "Эй, ты ничего не написал!"
		return erb :new
	end

	#   # Создаем папку для загрузок, если ее нет
  # Dir.mkdir('public/uploads') unless Dir.exist?('public/uploads')

  # filename = "#{Time.now.to_i}_#{image}"
  # filepath = "uploads/#{filename}"

  #     # Сохраняем файл
  #   File.open("public/#{filepath}", 'wb') do |f|
  #     f.write(image[:tempfile].read)
  #   end

	@db.execute 'INSERT INTO Posts (content, head, created_date) VALUES (?, ?, datetime())', [content, head]

	redirect to '/'

end

get '/post/:id' do  

  id = params[:id]

  @result = @db.execute 'SELECT * FROM Posts WHERE post_id = ?', [id]
  @row = @result[0]
  @comment = @db.execute 'SELECT * FROM Comment WHERE post_id = ? ORDER BY post_id DESC', [id]
  @error = params[:error]

  erb :post

end

post '/post/:id' do  

  id = params[:id]  
  content = params[:content].to_s.strip  
  user = $name_user

  if content.empty?  
    redirect to("/post/#{id}?error=Комментарий не может быть пустым!")  
  else  
    @db.execute 'INSERT INTO Comment (comment, created_date, post_id, name_user) VALUES (?, datetime(), ?, ?)', [content, id, user]  
    redirect to("/post/#{id}")  
  end  

end