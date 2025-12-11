CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  username varchar(255) NOT NULL UNIQUE,
  name varchar(255),
  surname varchar(255),
  email varchar(255) NOT NULL UNIQUE,
  created_at timestamp NOT NULL DEFAULT now(),
  birth_date date
);

CREATE TABLE IF NOT EXISTS users_scd2 (
  scd_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  id uuid NOT NULL,
  username varchar(255) NOT NULL,
  name varchar(255),
  surname varchar(255),
  email varchar(255) NOT NULL,
  created_at timestamp NOT NULL DEFAULT now(),
  birth_date date,
  start_dttm timestamp NOT NULL DEFAULT now(),
  end_dttm timestamp,
  is_current boolean NOT NULL DEFAULT true
);

CREATE TABLE IF NOT EXISTS posts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title varchar(320) NOT NULL,
  content text NOT NULL,
  author_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at timestamp NOT NULL DEFAULT now(),
  views integer NOT NULL DEFAULT 0
);

CREATE INDEX IF NOT EXISTS idx_posts_author ON posts(author_id);

CREATE TABLE IF NOT EXISTS posts_scd2 (
  scd_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  id uuid NOT NULL,
  title varchar(320) NOT NULL,
  content text NOT NULL,
  author_id uuid NOT NULL,
  created_at timestamp NOT NULL DEFAULT now(),
  views integer NOT NULL DEFAULT 0,
  start_dttm timestamp NOT NULL DEFAULT now(),
  end_dttm timestamp,
  is_current boolean NOT NULL DEFAULT true
);

CREATE TABLE IF NOT EXISTS comments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  content text NOT NULL,
  post_id uuid NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  author_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at timestamp NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_comments_post ON comments(post_id);
CREATE INDEX IF NOT EXISTS idx_comments_author ON comments(author_id);

-- SCD2 Comments
CREATE TABLE IF NOT EXISTS comments_scd2 (
  scd_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  id uuid NOT NULL,
  content text NOT NULL,
  post_id uuid NOT NULL,
  author_id uuid NOT NULL,
  created_at timestamp NOT NULL DEFAULT now(),
  start_dttm timestamp NOT NULL DEFAULT now(),
  end_dttm timestamp,
  is_current boolean NOT NULL DEFAULT true
);

CREATE TABLE IF NOT EXISTS friendships (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  friend_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at timestamp NOT NULL DEFAULT now(),
  CONSTRAINT chk_friendship_no_self CHECK (user_id <> friend_id)
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_friendships_pair ON friendships (
  LEAST(user_id, friend_id),
  GREATEST(user_id, friend_id)
);

CREATE INDEX IF NOT EXISTS idx_friendships_user ON friendships(user_id);
CREATE INDEX IF NOT EXISTS idx_friendships_friend ON friendships(friend_id);

CREATE TABLE IF NOT EXISTS friendships_scd2 (
  scd_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  id uuid NOT NULL,
  user_id uuid NOT NULL,
  friend_id uuid NOT NULL,
  created_at timestamp NOT NULL DEFAULT now(),
  start_dttm timestamp NOT NULL DEFAULT now(),
  end_dttm timestamp,
  is_current boolean NOT NULL DEFAULT true
);

CREATE TABLE IF NOT EXISTS likes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id uuid NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at timestamp NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_likes_user_post ON likes(user_id, post_id);
CREATE INDEX IF NOT EXISTS idx_likes_post ON likes(post_id);
CREATE INDEX IF NOT EXISTS idx_likes_user ON likes(user_id);
