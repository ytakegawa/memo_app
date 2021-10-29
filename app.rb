# frozen_string_literal: true

require "sinatra"
require "sinatra/reloader"
require "json"
require "cgi"

DB_PATH = "json/memo_db.json"
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
    @db_memos.each do |memo|
      if memo[:id] == id.to_i
        memo[:title] = @title
        memo[:body] = @body
      end
    end
  end

  def rewrite_json(memo_data)
    memo_to_hash = { memos: memo_data }
    File.open(DB_PATH, "w") { |file| JSON.dump(memo_to_hash, file) }
  end

  def self.delete_memo(id)
    @db_memos.each do |memo|
      @db_memos.delete(memo) if memo[:id] == id.to_i
    end
  end

  def self.match_id(id)
    match_memo = ""
    DB_DATA[:memos].each { |memo| match_memo = memo if memo[:id] == id.to_i }
    match_memo
  end
end

get "/" do
  @memos = DB_DATA[:memos]
  erb :index
end

get "/new" do
  erb :new
end

get "/memos/:id" do
  @memo = Memo.match_id(params[:id])
  if @memo == ""
    @error_message = "This URL is not valid."
    erb :error
  else
    erb :show
  end
end

get "/memos/*" do
  "this id is not found.."
end

get "/edit/:id" do
  @memo = Memo.match_id(params[:id])
  if @memo == ""
    @error_message = "This URL is not valid."
    erb :error
  else
    erb :edit
  end
end

post "/new" do
  memo = Memo.new(params[:title], params[:body])
  memo.rewrite_json(memo.add_memo)
  redirect "/"
end

patch "/edit-done/:id" do
  memo = Memo.new(params[:title], params[:body])
  memo.rewrite_json(memo.change_memo(params[:id]))
  redirect "/"
end

delete "/delete/:id" do
  Memo.delete_memo(params[:id])
  redirect "/"
end

error 404 do
  "404 not found sorry.."
end
