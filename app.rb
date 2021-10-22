# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'cgi'
require 'pg'

DB = PG.connect(dbname: 'memo_app')

class Memo
  attr_reader :title, :body

  def initialize(title, body)
    @title = CGI.escape_html title
    @body = CGI.escape_html body
  end

  def add_memo
    DB.exec("INSERT INTO memos (title,body) VALUES ('#{@title}','#{@body}')")
  end

  def self.match_id(id)
    DB.exec("SELECT * FROM memos WHERE id = #{id}").to_a
  end
end

get '/' do
  @memos = DB.exec('SELECT * FROM memos ORDER BY id').to_a
  erb :index
end

get '/new' do
  erb :new
end

get '/show/:id' do
  @memo = Memo.match_id(params[:id])[0]
  erb :show
end

get '/edit/:id' do
  @memo = Memo.match_id(params[:id])[0]
  erb :edit
end

post '/new' do
  memo = Memo.new(params[:title], params[:body])
  memo.add_memo
  redirect '/'
end

patch '/edit-done/:id' do
  memo = Memo.new(params[:title], params[:body])
  DB.exec("UPDATE memos SET title = '#{memo.title}', body = '#{memo.body}' WHERE id = '#{params[:id]}' ")
  redirect '/'
  erb :index
end

delete '/delete/:id' do
  DB.exec("DELETE FROM memos WHERE id = #{params['id']} ")
  redirect '/'
  erb :index
end

error 404 do
  '404 not found sorry..'
end
