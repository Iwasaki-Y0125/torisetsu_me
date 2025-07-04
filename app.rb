require 'sinatra'
require 'pg'

configure do
    db_url = ENV['DATABASE_URL']

    conn = if db_url && !db_url.empty?
        PG.connect(db_url)
      else
        PG.connect(
          dbname: 'torisetsu_db',
          user: 'postgres',
          password: 'password',
          host: 'db',
          port: 5432
        )
        end

set :conn, conn

set :bind, '0.0.0.0'
end

# クエリ例：このままだと起動時に実行されるので、実際はroute内かメソッドで使うほうが良い
get '/' do
    @title = 'わたしのトリセツ.me'
    erb :index
end

# bindの設定
configure do
  set :bind, '0.0.0.0'
end
