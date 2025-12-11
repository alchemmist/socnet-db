DO $$
BEGIN
    CREATE TEMP TABLE tmp_users (
        id uuid,
        username varchar,
        email varchar,
        name varchar,
        surname varchar,
        birth_date date,
        created_at timestamp
    );

    INSERT INTO tmp_users VALUES
        ('00000000-0000-0000-0000-000000000001', 'test_user', 'test@example.com', 'Test', 'User', '2000-01-01', now());

    CALL scd2_load_users();
END
$$;

DO $$
BEGIN
    CREATE TEMP TABLE tmp_posts (
        id uuid,
        title varchar,
        content text,
        author_id uuid,
        created_at timestamp,
        views integer
    );

    INSERT INTO tmp_posts VALUES
        ('00000000-0000-0000-0000-000000000001', 'Test Post', 'Some content', '00000000-0000-0000-0000-000000000001', now(), 0);

    CALL scd2_load_posts();
END
$$;

DO $$
BEGIN
    CREATE TEMP TABLE tmp_comments (
        id uuid,
        content text,
        post_id uuid,
        author_id uuid,
        created_at timestamp
    );

    INSERT INTO tmp_comments VALUES
        ('00000000-0000-0000-0000-000000000001', 'Test comment', '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', now());

    CALL scd2_load_comments();
END
$$;

DO $$
BEGIN
    CREATE TEMP TABLE tmp_friendships (
        id uuid,
        user_id uuid,
        friend_id uuid,
        created_at timestamp
    );

    INSERT INTO tmp_friendships VALUES
        ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', now());

    CALL scd2_load_friendships();
END
$$;

