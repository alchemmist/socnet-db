-- Try to insert not correct email
DO $$
BEGIN
    BEGIN
        INSERT INTO users (username, email, name, surname, birth_date)
        VALUES ('bad_user', 'not-an-email', 'Bad', 'User', '2000-01-01');
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'Expected error: %', SQLERRM;
    END;
END
$$;

-- Try to insert correct email
INSERT INTO users (username, email, name, surname, birth_date)
VALUES ('good_user', 'good@example.com', 'Good', 'User', '1995-05-05');

SELECT id, username, email FROM users WHERE username = 'good_user';

