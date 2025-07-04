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
# フォームから送られてきた値をparamsハッシュで受け取る
    @name = params[:name]
    @name_furigana = params[:name_furigana]
    @likes = params[:likes]
    @dislikes = params[:dislikes]
    @hobbies = params[:hobbies]
    @current_focus = params[:current_focus]
    @social_style = params[:social_style]
    @decision_style = params[:decision_style]
    @action_style = params[:action_style]
    @message = params[:message]
    erb :result  # views/result.erb
end

get '/result' do
    # GETでアクセスされた時の処理（必要なら）
    @result = "直接GETアクセスされました"
    erb :result
end

# 受け取った値を使って結果画面を表示
get '/profile_text' do
    erb :profile_text  # views/profile_text.erb
end
