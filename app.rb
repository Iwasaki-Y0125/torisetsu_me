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
  conn = settings.conn
  res = conn.exec("SELECT * FROM profiles;")

  if res.ntuples.zero?
    "データがありません"
  else
    res.map { |row| row.to_s }.join("<br>")
  end
end

# bindの設定
configure do
  set :bind, '0.0.0.0'
end
