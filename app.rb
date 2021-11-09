# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'cgi'
require 'pg'

DB = PG.connect(dbname: 'memo_app')
DB.exec('CREATE TABLE IF NOT EXISTS memos (id serial, title text not null, body text, PRIMARY KEY(id))')

helpers do
  def escape(text)
    CGI.escape_html(text)
  end
end

class Memo
  attr_reader :title, :body

  def initialize(title, body)
    @title = title
    @body = body
  end

  def add_memo
    DB.exec("INSERT INTO memos (title,body) VALUES ('#{@title}','#{@body}')")
  end

  def update_memo(id)
    DB.exec("UPDATE memos SET title = '#{@title}', body = '#{@body}' WHERE id = '#{id}' ")
  end

  def self.show_memo
    DB.exec('SELECT * FROM memos ORDER BY id').to_a
  end

  def self.match_id(id)
    DB.exec("SELECT * FROM memos WHERE id = #{id}").to_a
  end

  def self.delete_memo(id)
    DB.exec("DELETE FROM memos WHERE id = #{id} ")
  end
end

get '/' do
  @memos = Memo.show_memo
  erb :index
end

get '/memos/new' do
  erb :new
end

get '/memos/:id' do
  @memo = Memo.match_id(params[:id])[0]
  if @memo.nil?
    @error_message = 'This URL is not valid.'
    erb :error
  else
    erb :show
  end
end

get '/memos/:id/edit' do
  @memo = Memo.match_id(params[:id])[0]
  if @memo.nil?
    @error_message = 'This URL is not valid.'
    erb :error
  else
    erb :edit
  end
end

post '/memos/new' do
  memo = Memo.new(params[:title], params[:body])
  memo.add_memo
  redirect '/'
end

patch '/memos/:id' do
  memo = Memo.new(params[:title], params[:body])
  memo.update_memo(params[:id])
  redirect '/'
end

delete '/memos/:id' do
  Memo.delete_memo(params[:id])
  redirect '/'
end

error 404 do
  '404 not found sorry..'
end
