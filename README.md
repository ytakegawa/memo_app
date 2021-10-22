# This is a MEMO Application

# このアプリについて
テキストをメモとして保存、閲覧、変更、削除ができるシンプルなメモアプリです。

# 使い方
1. リポジトリをクローン
   git clone https://github.com/ytakegawa/memo_app.git
2. PostgreSQLを用意
3. DBを作成する
  CREATE DATABASE memo_app;
4. データテーブルを作成する
  CREATE TABLE memos (id serial, title text not null, body text, PRIMARY KEY(id));
5. ターミナルで`bundle exec ruby app.rb`を実行
6. ブラウザでhttp://localhost:4567/にアクセス

# 更新情報
ver.1 メモ情報をJSONファイルに格納して読み込む仕様
ver.2 メモ情報をDBに格納して読み込む仕様
