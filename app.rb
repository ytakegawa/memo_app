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

class Memo
  def initialize(title, body)
    @title = title
    @body = body
    @db_memos = DB_DATA[:memos]
  end

  def add_memo
    id = @db_memos.empty? ? 1 : @db_memos[-1][:id] + 1
    @db_memos << { id: id, title: @title, body: @body }
  end

  def change_memo(id)
    DB_DATA[:memos].each do |memo|
      if memo[:id] == id.to_i
        memo[:title] = @title
        memo[:body] = @body
      end
    end
  end

  def rewrite_json(memo_data)
    memo_to_hash = { memos: memo_data }
    File.open(DB_PATH, 'w') { |file| JSON.dump(memo_to_hash, file) }
  end

  def self.delete_memo(id)
    DB_DATA[:memos].each do |memo|
      DB_DATA[:memos].delete(memo) if memo[:id] == id.to_i
    end
  end

  def self.match_id(id)
    DB_DATA[:memos].find { |memo| memo[:id] == id.to_i }
  end
end

get '/' do
  @memos = DB_DATA[:memos]
  erb :index
end

get '/memos/new' do
  erb :new
end

get '/memos/:id' do
  @memo = Memo.match_id(params[:id])
  if @memo.nil?
    @error_message = 'This URL is not valid.'
    erb :error
  else
    erb :show
  end
end

get '/memos/:id/edit' do
  @memo = Memo.match_id(params[:id])
  if @memo.nil?
    @error_message = 'This URL is not valid.'
    erb :error
  else
    erb :edit
  end
end

post '/memos/new' do
  memo = Memo.new(params[:title], params[:body])
  memo.rewrite_json(memo.add_memo)
  redirect '/'
end

patch '/memos/:id/edit-done' do
  memo = Memo.new(params[:title], params[:body])
  memo.rewrite_json(memo.change_memo(params[:id]))
  redirect '/'
end

delete '/memos/:id/delete' do
  Memo.delete_memo(params[:id])
  redirect '/'
end

error 404 do
  '404 not found sorry..'
end
