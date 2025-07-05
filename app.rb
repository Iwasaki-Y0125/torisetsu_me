require 'sinatra'
require 'pg'
require 'securerandom'
require 'json'

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

get '/edit' do
    @category = session[:category]|| ''
    @category_custom = session[:category_custom]|| ''
    @name = session[:name]|| ''
    @name_furigana = session[:name_furigana]|| ''
    @avatar = session[:avatar]|| ''
    @questions = session[:questions]|| []
    @question_customs = session[:question_customs]|| []
    @answers = session[:answers]|| []
    @message = session[:message]|| ''

    erb :edit
end

post '/result' do

uuid = SecureRandom.uuid

category = params[:category]
category_custom = params[:category_custom]
name = params[:name]
name_furigana = params[:name_furigana]
avatar = params[:avatar]
questions = params[:questions] || []
question_customs = params[:question_customs] || []
answers = params[:answers] || []
message = params[:message]

session[:share_url] = "#{request.base_url}/share/#{uuid}"
session[:uuid] = uuid
session[:category] = category
session[:category_custom] = category_custom
session[:name] = name
session[:name_furigana] = name_furigana
session[:questions] = questions
session[:question_customs] = question_customs
session[:answers] = answers
session[:message] = message

questions = questions.to_json
question_customs = question_customs.to_json
answers = answers.to_json

# DBに保存
conn = settings.conn
conn.exec_params(
    "INSERT INTO profiles (uuid, category, category_custom, name, name_furigana, avatar, questions, question_customs, answers, message)
    VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)",
    [
    uuid,
    category,
    category_custom,
    name,
    name_furigana,
    avatar,
    questions,
    question_customs,
    answers,
    message
    ]
)

redirect '/result'
end

get '/result' do
# セッションの値をインスタンス変数に渡す
@category = session[:category]
@category_custom = session[:category_custom]
@name = session[:name]
@name_furigana = session[:name_furigana]
@avatar = session[:avatar]
@questions = session[:questions]
@question_customs = session[:question_customs]
@answers = session[:answers]
@message = session[:message]
@share_url = session[:share_url]

erb :result
end

get '/share/:uuid' do
uuid = params[:uuid]
# DBからuuidに対応するデータを取得
result = settings.conn.exec_params("SELECT * FROM profiles WHERE uuid = $1", [uuid])

if result.ntuples == 0
    status 404
    return "指定されたプロフィールは存在しません"
end

raw = result[0]

@profile = {
"uuid" => raw["uuid"],
"name" => raw["name"],
"name_furigana" => raw["name_furigana"],
"category" => raw["category"],
"category_custom" => raw["category_custom"],
"avatar" => raw["avatar"],
"questions" => JSON.parse(raw["questions"]),
"question_customs" => JSON.parse(raw["question_customs"]),
"answers" => JSON.parse(raw["answers"]),
"message" => raw["message"]
}

erb :share  # 共有画面テンプレート
end
