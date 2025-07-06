DROP TABLE IF EXISTS profiles CASCADE;

CREATE TABLE profiles (
    id SERIAL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL,
    name TEXT NOT NULL,
    name_furigana TEXT,
    category TEXT,
    category_custom TEXT,
    category_me TEXT,
    category_me_custom TEXT,
    avatar TEXT,
    questions JSONB,
    question_customs JSONB,
    answers JSONB,
    message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CHECK (
    COALESCE(jsonb_array_length(questions), 0) = COALESCE(jsonb_array_length(answers), 0)
    )
);
