CREATE TABLE IF NOT EXISTS users_scd2 (
    scd_id uuid PRIMARY KEY DEFAULT gen_random_uuid (),
    id uuid NOT NULL,
    username varchar(255) NOT NULL,
    name varchar(255),
    surname varchar(255),
    email varchar(255) NOT NULL,
    created_at timestamp NOT NULL DEFAULT now(),
    birth_date date,
    start_dttm timestamp NOT NULL DEFAULT now(),
    end_dttm timestamp,
    is_current boolean NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS posts_scd2 (
    scd_id uuid PRIMARY KEY DEFAULT gen_random_uuid (),
    id uuid NOT NULL,
    title varchar(320) NOT NULL,
    content text NOT NULL,
    author_id uuid NOT NULL,
    created_at timestamp NOT NULL DEFAULT now(),
    views integer NOT NULL DEFAULT 0,
    start_dttm timestamp NOT NULL DEFAULT now(),
    end_dttm timestamp,
    is_current boolean NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS comments_scd2 (
    scd_id uuid PRIMARY KEY DEFAULT gen_random_uuid (),
    id uuid NOT NULL,
    content text NOT NULL,
    post_id uuid NOT NULL,
    author_id uuid NOT NULL,
    created_at timestamp NOT NULL DEFAULT now(),
    start_dttm timestamp NOT NULL DEFAULT now(),
    end_dttm timestamp,
    is_current boolean NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS friendships_scd2 (
    scd_id uuid PRIMARY KEY DEFAULT gen_random_uuid (),
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    friend_id uuid NOT NULL,
    created_at timestamp NOT NULL DEFAULT now(),
    start_dttm timestamp NOT NULL DEFAULT now(),
    end_dttm timestamp,
    is_current boolean NOT NULL DEFAULT TRUE
);

CREATE OR REPLACE PROCEDURE scd2_load_users ()
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE
        users_scd2 u
    SET
        end_dttm = now(),
        is_current = FALSE
    FROM
        tmp_users t
    WHERE
        u.id = t.id
        AND u.is_current = TRUE
        AND (u.username IS DISTINCT FROM t.username
            OR u.email IS DISTINCT FROM t.email
            OR u.name IS DISTINCT FROM t.name
            OR u.surname IS DISTINCT FROM t.surname
            OR u.birth_date IS DISTINCT FROM t.birth_date);
    INSERT INTO users_scd2 (id, username, name, surname, email, birth_date, created_at, start_dttm, end_dttm, is_current)
    SELECT
        t.id,
        t.username,
        t.name,
        t.surname,
        t.email,
        t.birth_date,
        t.created_at,
        now(),
        NULL,
        TRUE
    FROM
        tmp_users t
        LEFT JOIN users_scd2 u ON u.id = t.id
            AND u.is_current = TRUE
    WHERE
        u.id IS NULL
        OR u.username IS DISTINCT FROM t.username
        OR u.email IS DISTINCT FROM t.email
        OR u.name IS DISTINCT FROM t.name
        OR u.surname IS DISTINCT FROM t.surname
        OR u.birth_date IS DISTINCT FROM t.birth_date;
END;
$$;

CREATE OR REPLACE PROCEDURE scd2_load_posts ()
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE
        posts_scd2 p
    SET
        end_dttm = now(),
        is_current = FALSE
    FROM
        tmp_posts t
    WHERE
        p.id = t.id
        AND p.is_current = TRUE
        AND (p.title IS DISTINCT FROM t.title
            OR p.content IS DISTINCT FROM t.content
            OR p.author_id IS DISTINCT FROM t.author_id
            OR p.views IS DISTINCT FROM t.views);
    INSERT INTO posts_scd2 (id, title, content, author_id, created_at, views, start_dttm, end_dttm, is_current)
    SELECT
        t.id,
        t.title,
        t.content,
        t.author_id,
        t.created_at,
        t.views,
        now(),
        NULL,
        TRUE
    FROM
        tmp_posts t
        LEFT JOIN posts_scd2 p ON p.id = t.id
            AND p.is_current = TRUE
    WHERE
        p.id IS NULL
        OR p.title IS DISTINCT FROM t.title
        OR p.content IS DISTINCT FROM t.content
        OR p.author_id IS DISTINCT FROM t.author_id
        OR p.views IS DISTINCT FROM t.views;
END;
$$;

CREATE OR REPLACE PROCEDURE scd2_load_comments ()
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE
        comments_scd2 c
    SET
        end_dttm = now(),
        is_current = FALSE
    FROM
        tmp_comments t
    WHERE
        c.id = t.id
        AND c.is_current = TRUE
        AND (c.content IS DISTINCT FROM t.content
            OR c.post_id IS DISTINCT FROM t.post_id
            OR c.author_id IS DISTINCT FROM t.author_id);
    INSERT INTO comments_scd2 (id, content, post_id, author_id, created_at, start_dttm, end_dttm, is_current)
    SELECT
        t.id,
        t.content,
        t.post_id,
        t.author_id,
        t.created_at,
        now(),
        NULL,
        TRUE
    FROM
        tmp_comments t
        LEFT JOIN comments_scd2 c ON c.id = t.id
            AND c.is_current = TRUE
    WHERE
        c.id IS NULL
        OR c.content IS DISTINCT FROM t.content
        OR c.post_id IS DISTINCT FROM t.post_id
        OR c.author_id IS DISTINCT FROM t.author_id;
END;
$$;

CREATE OR REPLACE PROCEDURE scd2_load_friendships ()
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE
        friendships_scd2 f
    SET
        end_dttm = now(),
        is_current = FALSE
    FROM
        tmp_friendships t
    WHERE
        f.id = t.id
        AND f.is_current = TRUE
        AND (f.user_id IS DISTINCT FROM t.user_id
            OR f.friend_id IS DISTINCT FROM t.friend_id);
    INSERT INTO friendships_scd2 (id, user_id, friend_id, created_at, start_dttm, end_dttm, is_current)
    SELECT
        t.id,
        t.user_id,
        t.friend_id,
        t.created_at,
        now(),
        NULL,
        TRUE
    FROM
        tmp_friendships t
        LEFT JOIN friendships_scd2 f ON f.id = t.id
            AND f.is_current = TRUE
    WHERE
        f.id IS NULL
        OR f.user_id IS DISTINCT FROM t.user_id
        OR f.friend_id IS DISTINCT FROM t.friend_id;
END;
$$;

