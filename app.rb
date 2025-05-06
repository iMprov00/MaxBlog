require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

enable :sessions

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

	login = params[:login]
	password = params[:password]

	 # Ищем пользователя
  user = @db.execute('SELECT * FROM Users WHERE username = ?', login).first

  if user && user['password_hash'] == password
  			$cur_us = 1
  	    redirect '/'
  elsif 
  	@error = "Неверный логин или пароль"
    erb :authorization
  end
  	

end