DROP TABLE IF EXISTS profiles CASCADE;

CREATE TABLE profiles (
    id SERIAL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL,
    name TEXT NOT NULL,
    name_furigana TEXT,
    category TEXT,
    category_custom TEXT,
    questions TEXT[],
    question_customs TEXT[],
    answers TEXT[],
    message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CHECK (
    array_length(questions, 1) = array_length(answers, 1)
    )
);
