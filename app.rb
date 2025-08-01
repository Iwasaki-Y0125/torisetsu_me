require 'sinatra'
require 'erb'
require 'pg'
require 'securerandom'
require 'json'
require 'rmagick'



#アプリ起動時に一度だけ実行される初期設定の場所 configure do ... end
configure do
  # 環境判定
  is_production = ENV['DATABASE_URL'] && !ENV['DATABASE_URL'].empty?
  ssl_mode = ENV['DATABASE_SSL_MODE'] || (is_production ? 'require' : 'disable')

  # データベース接続
  conn = begin
    if is_production
    puts "Production mode: Connecting with SSL"
    PG.connect(ENV['DATABASE_URL'], sslmode: ssl_mode)
    else
    puts "Development mode: Connecting locally"
    PG.connect(
      dbname: 'torisetsu_db',
      user: 'postgres',
      password: 'password',
      host: 'db',
      port: 5432,
      sslmode: 'disable'
    )
  end
  rescue PG::Error => e
    puts "Database connection failed: #{e.message}"
    raise e
  end

  puts "Database connected successfully with SSL mode: #{ssl_mode}"
  set :conn, conn

  # セッション設定
  session_secret = ENV['SESSION_SECRET'] ||
                    (is_production ? nil : 'dev_secret_change_in_production')

  if session_secret.nil?
    raise "SESSION_SECRET is required in production"
  end

  enable :sessions
  set :session_secret, session_secret
  set :bind, '0.0.0.0'
  set :port, ENV['PORT'] || 4567
end

# XSS（クロスサイトスクリプティング）対策のコード  <%= h @message %>
helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

# UUID取得
helpers do
  def find_profile_by_uuid(uuid)
    uuid = uuid.to_s.strip
    result = settings.conn.exec_params("SELECT * FROM profiles WHERE uuid = $1", [uuid])
    if result.ntuples == 0
      halt 404, "指定されたプロフィールは存在しません"
    end
  result[0]
  end
end

#* ルーティング
get '/' do
    @title = 'わたしのトリセツ.me'
    erb :top   # views/top.erb
end

# *編集画面
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

#* ポストリザルト画面
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

# *GET　リザルト画面
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

# *GET シェア画面
get '/share/:uuid' do

uuid = params[:uuid]
raw = find_profile_by_uuid(uuid)  # UUIDハッシュ値を取得

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
category_me_custom = raw["category_me_custom"]

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

# *　入力クリア
post '/clear_session_and_redirect' do
  session.clear
  redirect '/edit'
end

# *　OGP設定　
get '/ogp/:uuid.png' do
  content_type 'image/png'

  uuid = params[:uuid]
  raw = find_profile_by_uuid(uuid)  # UUIDハッシュ値を取得

  # データを整理
  category = raw["category"]
  category_custom = raw["category_custom"]
  final_category = (category == 'other' && !category_custom.to_s.strip.empty?) ? category_custom : category

  category_me = raw["category_me"]
  category_me_custom = raw["category_me_custom"]
  final_category_me = (category_me == 'other' && !category_me_custom.to_s.strip.empty?) ? category_me_custom : category_me

  name = raw["name"]

  questions = JSON.parse(raw["questions"])
  question_customs = JSON.parse(raw["question_customs"])
  final_questions = questions.map.with_index do |q, i|
    (q == 'other' && !question_customs[i].to_s.strip.empty?) ? question_customs[i] : q
  end

  answers = JSON.parse(raw["answers"])

  # アバター画像を読み込み＆リサイズ（必要なら）
  avatar_filename = raw["avatar"]
  avatar_path = "./public/avatars/#{avatar_filename}"
  avatar = Magick::Image.read(avatar_path).first.resize_to_fill(320, 320)

  # 画像の作成
  ogp_image = Magick::Image.new(1200, 630)
  ogp_image.background_color = '#e0e0e0'
  ogp_image.border!(30, 20, '#4d4c4b')

  draw = Magick::Draw.new
  draw.font = './public/fonts/JF-Dot-k12x10.ttf'
  draw.interline_spacing = 20
  draw.fill = '#4d4c4b'
  # draw.text_antialias = true

  # テキスト描画位置と内容
  draw.annotate(ogp_image, 0, 0, 0, 90, "#{final_category} の #{name}のトリセツ")do |d|
  d.pointsize = 50
  d.stroke    = '#4d4c4b'
  d.gravity   = Magick::NorthGravity
end

  draw.annotate(ogp_image, 0, 0, 450, 200, "#{(final_questions[0] || 'なし').gsub(/(.{20})/, "\\1\n")}")do |d|
  d.pointsize = 30
  d.gravity   = Magick::NorthWestGravity
end

  draw.annotate(ogp_image, 0, 0, 450, 360, "#{(answers[0] || 'なし').gsub(/(.{14})/, "\\1\n")}")do |d|
  d.pointsize = 40
  d.gravity   = Magick::NorthWestGravity
end


  draw.annotate(ogp_image, 10, 10, 800, 600, "わたしのトリセツ.me")do |d|
  d.pointsize = 30
  d.gravity   = Magick::NorthWestGravity
end


  # アバター画像を合成
  ogp_image.composite!(avatar, 100, 200, Magick::OverCompositeOp)


  ogp_image.format = 'PNG'
  ogp_image.to_blob
end
