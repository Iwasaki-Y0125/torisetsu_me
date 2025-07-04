require 'sinatra'
require 'pg'

enable :sessions

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
    @profile_type = session[:profile_type]|| ''
    @name = session[:name]|| ''
    @name_furigana = session[:name_furigana]|| ''
    @likes = session[:likes]|| ''
    @dislikes = session[:dislikes]|| ''
    @hobbies = session[:hobbies]|| ''
    @current_focus = session[:current_focus]|| ''
    @social_style = session[:social_style]|| ''
    @decision_style = session[:decision_style]|| ''
    @action_style = session[:action_style]|| ''
    @message = session[:message]|| ''

    erb :input
end

post '/result' do
# パラメータを受け取る
profile_type = params[:profile_type]
name = params[:name]
name_furigana = params[:name_furigana]
likes = params[:likes]
dislikes = params[:dislikes]
hobbies = params[:hobbies]
current_focus = params[:current_focus]
social_style = params[:social_style]
decision_style = params[:decision_style]
action_style = params[:action_style]
message = params[:message]

# DBに保存
conn = settings.conn
conn.exec_params(
    "INSERT INTO profiles (profile_type,name, name_furigana, likes, dislikes, hobbies, current_focus, social_style, decision_style, action_style, message)
    VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)",
    [
    profile_type,
    name,
    name_furigana,
    likes,
    dislikes,
    hobbies,
    current_focus,
    social_style,
    decision_style,
    action_style,
    message
    ]
)

# セッションに保存
session[:profile_type] = profile_type
session[:name] = name
session[:name_furigana] = name_furigana
session[:likes] = likes
session[:dislikes] = dislikes
session[:hobbies] = hobbies
session[:current_focus] = current_focus
session[:social_style] = social_style
session[:decision_style] = decision_style
session[:action_style] = action_style
session[:message] = message


# 結果画面用のインスタンス変数をセット
@profile_type = profile_type
@name = name
@name_furigana = name_furigana
@likes = likes
@dislikes = dislikes
@hobbies = hobbies
@current_focus = current_focus
@social_style = social_style
@decision_style = decision_style
@action_style = action_style
@message = message

redirect '/result'
end

get '/result' do
    # セッションの値をインスタンス変数に渡す
    @profile_type = session[:profile_type]
    @name = session[:name]
    @name_furigana = session[:name_furigana]
    @likes = session[:likes]
    @dislikes = session[:dislikes]
    @hobbies = session[:hobbies]
    @current_focus = session[:current_focus]
    @social_style = session[:social_style]
    @decision_style = session[:decision_style]
    @action_style = session[:action_style]
    @message = session[:message]

    erb :result
end

# 受け取った値を使って結果画面を表示
get '/profile_text' do
    erb :profile_text  # views/profile_text.erb
end
