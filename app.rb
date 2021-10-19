# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'cgi'

DB_PATH = 'json/memo_db.json'
DB_DATA =
  File.open(DB_PATH) do |file|
    JSON.parse(file.read, symbolize_names: true)
  end
DB_MEMOS = DB_DATA[:memos]

class Memo
  def initialize(title, body)
    @id = DB_MEMOS.empty? ? 1 : DB_MEMOS[-1][:id] + 1
    @title = title
    @body = body
  end

  def add_memo
    new_memo = { id: @id, title: @title, body: @body }
    DB_MEMOS << new_memo
  end

  def self.rewrite_json(memo_data)
    memo_to_hash = { memos: memo_data }
    File.open(DB_PATH, 'w') { |file| JSON.dump(memo_to_hash, file) }
  end

  def self.match_id(id)
    match_memo = ''
    DB_MEMOS.each { |memo| match_memo = memo if memo[:id] == id.to_i }
    match_memo
  end
end

get '/' do
  @memos = DB_MEMOS
  erb :index
end

get '/new' do
  erb :new
end

get '/show/:id' do
  @memo = Memo.match_id(params[:id])
  erb :show
end

get '/edit/:id' do
  @memo = Memo.match_id(params[:id])
  erb :edit
end

post '/new' do
  memo = Memo.new(CGI.escape_html(params[:title]), CGI.escape_html(params[:body]))
  Memo.rewrite_json(memo.add_memo)
  redirect '/'
end

patch '/edit-done/:id' do
  match_memo = Memo.match_id(params[:id])
  change_memo =
    DB_MEMOS.each do |memo|
      if memo[:id] == match_memo[:id].to_i
        memo[:title] = CGI.escape_html(params[:title])
        memo[:body] = CGI.escape_html(params[:body])
      end
    end
  Memo.rewrite_json(change_memo)
  redirect '/'
  erb :index
end

delete '/delete/:id' do
  delete_memo =
    DB_MEMOS.each do |memo|
      DB_MEMOS.delete(memo) if memo[:id] == params[:id].to_i
    end
  Memo.rewrite_json(delete_memo)
  redirect '/'
  erb :index
end
