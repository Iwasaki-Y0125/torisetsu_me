require 'sinatra'
require 'erb'
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

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

get '/' do
    @title = 'わたしのトリセツ.me'
    erb :top   # views/top.erb
end

get '/edit' do
    @category = session[:category]|| ''
    @category_custom = session[:category_custom]|| ''
    @category_me = session[:category_me]|| ''
    @category_me_custom = session[:category_me_custom]|| ''
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
category_me = params[:category_me]
category_me_custom = params[:category_me_custom]
name = params[:name]
name_furigana = params[:name_furigana]
avatar = params[:avatar]
questions = params[:questions] || []
question_customs = params[:question_customs] || []
answers = params[:answers] || []
message = params[:message]

category_custom_str = category_custom.to_s.strip
final_category =
  if category == 'other' && !category_custom_str.empty?
    category_custom_str
else
    category
end

category_me_custom_str = category_me_custom.to_s.strip
final_category_me =
  if category_me == 'other' && !category_me_custom_str.empty?
    category_me_custom_str
else
  category_me
end

final_questions = questions.map.with_index do |q, i|
  questions_custom_str = question_customs[i].to_s.strip
    if q == 'other' && !questions_custom_str.empty?
      questions_custom_str
  else
      q
  end
end

session[:share_url] = "#{request.base_url}/share/#{uuid}"
session[:uuid] = uuid
session[:category] = category
session[:category_custom] = category_custom
session[:final_category] = final_category
session[:category_me] = category_me
session[:category_me_custom] = category_me_custom
session[:final_category_me] = final_category_me
session[:name] = name
session[:name_furigana] = name_furigana
session[:avatar] = avatar
session[:questions] = questions
session[:question_customs] = question_customs
session[:final_questions] = final_questions
session[:answers] = answers
session[:message] = message

questions = questions.to_json
question_customs = question_customs.to_json
answers = answers.to_json

# DBに保存
conn = settings.conn
conn.exec_params(
    "INSERT INTO profiles (uuid, category, category_custom, category_me, category_me_custom, name, name_furigana, avatar, questions, question_customs, answers, message)
    VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)",
    [
    uuid,
    category,
    category_custom,
    category_me,
    category_me_custom,
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
@final_category = session[:final_category]
@final_category_me = session[:final_category_me]
@name = session[:name]
@name_furigana = session[:name_furigana]
@avatar = session[:avatar]
@final_questions = session[:final_questions]
@answers = session[:answers]
@message = session[:message]
@share_url = session[:share_url]

erb :result
end

get '/share/:uuid' do
uuid = params[:uuid]

result = settings.conn.exec_params("SELECT * FROM profiles WHERE uuid = $1", [uuid])

if result.ntuples == 0
  status 404
  return "指定されたプロフィールは存在しません"
end

raw = result[0]

category = raw["category"]
category_custom = raw["category_custom"]

category_custom_str = category_custom.to_s.strip
final_category =
  if category == 'other' && !category_custom.strip.empty?
    category_custom_str
else
  category
end

category_me = raw["category_me"]
category_me_custom = raw["category_custom_me"]

category_me_custom_str = category_me_custom.to_s.strip
final_category_me =
  if category_me == 'other' && !category_me_custom.strip.empty?
    category_me_custom_str
else
  category_me
end

questions = JSON.parse(raw["questions"])
question_customs = JSON.parse(raw["question_customs"])

final_questions = questions.map.with_index do |q, i|
  questions_custom_str = question_customs[i].to_s.strip
  if q == 'other' && !questions_custom_str.empty?
    questions_custom_str
  else
    q
  end
end

@profile = {
"uuid" => raw["uuid"],
"name" => raw["name"],
"name_furigana" => raw["name_furigana"],
"avatar" => raw["avatar"],
"category" => category,
"category_custom" => category_custom,
"final_category" => final_category,
"category_me" => category_me,
"category_me_custom" => category_me_custom,
"final_category_me" => final_category_me,
"questions" => questions,
"question_customs" => question_customs,
"final_questions" => final_questions,
"answers" => JSON.parse(raw["answers"]),
"message" => raw["message"]
}

erb :share
end

post '/clear_session_and_redirect' do
  session.clear
  redirect '/edit'
end
