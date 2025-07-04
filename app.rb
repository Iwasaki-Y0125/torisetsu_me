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

get '/' do
    @title = 'わたしのトリセツ.me'
    erb :top   # views/top.erb
  end

  get '/input' do
    erb :input  # views/input.erb
  end

  post '/result' do
    # フォームからの入力を処理して結果を表示
    @result = params[:something]
    erb :result  # views/result.erb
  end

  get '/profile' do
    erb :profile  # views/profile.erb
  end
