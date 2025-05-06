require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db 
	@db = SQLite3::Database.new 'blog.db'
	@db.results_as_hash = true
end


before do 

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

	@current_user = 0
	erb "Hello!"

end

get '/authorization' do 

	erb :authorization

end