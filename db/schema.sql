DROP TABLE IF EXISTS profiles CASCADE;

-- 既存型を削除（必要に応じて）
DROP TYPE IF EXISTS profile_type_enum CASCADE;
DROP TYPE IF EXISTS social_style_enum CASCADE;
DROP TYPE IF EXISTS decision_style_enum CASCADE;
DROP TYPE IF EXISTS action_style_enum CASCADE;


-- ENUM型の作成
CREATE TYPE profile_type_enum AS ENUM ('workplace', 'circle', 'sns');

CREATE TYPE social_style_enum AS ENUM (
  '社交型',
  '八方美人',
  '内向型'
);

CREATE TYPE decision_style_enum AS ENUM (
  '感情型',
  'バランス型',
  '論理型'
);

CREATE TYPE action_style_enum AS ENUM (
  'ムードメーカー',
  '柔軟型',
  '計画的'
);

-- テーブル作成
CREATE TABLE profiles (
  id SERIAL PRIMARY KEY,
  profile_type profile_type_enum NOT NULL,
  name TEXT NOT NULL,
  name_furigana TEXT,
  likes TEXT,
  dislikes TEXT,
  hobbies TEXT,
  current_focus TEXT,
  social_style social_style_enum NOT NULL,
  decision_style decision_style_enum NOT NULL,
  action_style action_style_enum NOT NULL,
  message TEXT,
  url TEXT,
  profile_text TEXT,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
