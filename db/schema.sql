DROP TABLE IF EXISTS profiles CASCADE;
-- 既存型を削除（必要に応じて）
DROP TYPE IF EXISTS profile_type_enum CASCADE;
DROP TYPE IF EXISTS social_style_enum CASCADE;
DROP TYPE IF EXISTS decision_style_enum CASCADE;
DROP TYPE IF EXISTS action_style_enum CASCADE;

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ENUM型の作成
CREATE TYPE profile_type_enum AS ENUM (
  'work',
  'circle',
  'sns'
);

CREATE TYPE social_style_enum AS ENUM (
  'sociable',
  'both',
  'solitude'
);

CREATE TYPE decision_style_enum AS ENUM (
  'emotional',
  'balance',
  'theorists'
);

CREATE TYPE action_style_enum AS ENUM (
  'freedom',
  'flexibility',
  'systematic'
);

-- テーブル作成
CREATE TABLE profiles (
  id SERIAL PRIMARY KEY,
  uuid UUID NOT NULL DEFAULT gen_random_uuid(),
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
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
