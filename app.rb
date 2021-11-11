# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'cgi'

DB_PATH = 'json/memo_db.json'

helpers do
  def escape(text)
    CGI.escape_html(text)
  end
end

class Memo
  def initialize(id, title, body)
    @id = id
    @title = title
    @body = body
  end

  def to_hash
    {
      id: @id,
      title: @title,
      body: @body,
    }
  end

  def save_memo
    memos = Memo.load_memo
    if @id.nil?
      @id = memos.empty? ? '1' : (memos.last[:id].to_i + 1).to_s
      memos << to_hash
    else
      memos.map! { |memo| memo[:id] == @id ? to_hash : memo }
    end
    memo_to_hash = { memos: memos }
    File.open(DB_PATH, 'w') { |file| JSON.dump(memo_to_hash, file) }
  end

  def self.load_memo
    db_load =
      File.open(DB_PATH) do |file|
        JSON.parse(file.read, symbolize_names: true)
      end
    db_load[:memos]
  end

  def self.delete_memo(id)
    memos = Memo.load_memo
    delete_memo = memos.each { |memo| memo[:id] == id ? memos.delete(memo) : memo }
    memo_to_hash = { memos: delete_memo }
    File.open(DB_PATH, 'w') { |file| JSON.dump(memo_to_hash, file) }
  end

  def self.match_id(id)
    Memo.load_memo.find { |memo| memo[:id] == id }
  end
end

get '/' do
  @memos = Memo.load_memo
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
  memo = Memo.new(params[:id], params[:title], params[:body])
  memo.save_memo
  redirect '/'
end

patch '/memos/:id' do
  memo = Memo.new(params[:id], params[:title], params[:body])
  memo.save_memo
  redirect '/'
end

delete '/memos/:id' do
  Memo.delete_memo(params[:id])
  redirect '/'
end

error 404 do
  '404 not found sorry..'
end
