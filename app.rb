require 'sinatra'
require 'pg'

configure do
  set :db_config, {
    dbname: 'torisetsu_db',
    user: 'postgres',
    password: 'password',
    host: 'db',
    port: 5432
  }

  # DB接続開始（シンプルに1回だけ開く例）
  conn = PG.connect(settings.db_config)
  set :conn, conn  # Sinatraのsettingsに保存
end

# クエリ例：このままだと起動時に実行されるので、実際はroute内かメソッドで使うほうが良い
get '/' do
  conn = settings.conn
  res = conn.exec("SELECT * FROM users;")
  res.map { |row| row.to_s }.join("<br>")
end

# bindの設定
configure do
  set :bind, '0.0.0.0'
end
