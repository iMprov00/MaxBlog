require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db 
	@db = SQLite3::Database.new 'blog.db'
	@db.results_as_hash = true
end

$cur_us = 0

before do 

	@current_user = $cur_us
	init_db

end

configure do 

	init_db

	@db.execute 'CREATE TABLE IF NOT EXISTS Users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT,
  password_hash TEXT,
  is_admin BOOLEAN DEFAULT 0,
  created_at DATE
)'

end

get '/' do 


	erb "Hello!"

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

  @db.execute 'INSERT INTO Users (username, password_hash, created_at) VALUES (?, ?, datetime())', [login, password]

  redirect to '/'

end