require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db 
	@db = SQLite3::Database.new 'blog.db'
	@db.results_as_hash = true
end