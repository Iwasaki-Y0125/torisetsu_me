DROP TABLE IF EXISTS profiles CASCADE;
DROP TABLE IF EXISTS questions CASCADE;

-- profiles テーブル: 各カテゴリ（〜用）ごとのプロフィール
CREATE TABLE profiles (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    name_furigana TEXT,
    category TEXT NOT NULL,
    uuid UUID UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- questions テーブル: 各プロフィールに紐づく質問と回答
CREATE TABLE questions (
    id SERIAL PRIMARY KEY,
    profile_id INTEGER NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    question TEXT NOT NULL,
    answer TEXT NOT NULL,
    is_custom BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
