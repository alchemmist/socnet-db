-- Для каждого пользователя считаем "индекс вовлечённости":
-- (комментарии + лайки на его постах) / (его собственные действия(посты + комментарии + лайки))
-- Ранжируем пользователей по индексу.
-- Используем оконную функцию RANK

WITH user_posts AS (
    SELECT
        u.id AS user_id,
        COUNT(p.id) AS post_count
    FROM
        users u
        LEFT JOIN posts p ON p.author_id = u.id
    GROUP BY
        u.id
),
user_comments AS (
    SELECT
        u.id AS user_id,
        COUNT(c.id) AS comment_count
    FROM
        users u
        LEFT JOIN comments c ON c.author_id = u.id
    GROUP BY
        u.id
),
user_likes AS (
    SELECT
        u.id AS user_id,
        COUNT(l.id) AS like_count
    FROM
        users u
        LEFT JOIN likes l ON l.user_id = u.id
    GROUP BY
        u.id
),
engagement AS (
    SELECT
        u.id AS user_id,
        COALESCE(pc.comments_on_posts, 0) + COALESCE(pl.likes_on_posts, 0) AS engagement_received,
        COALESCE(up.post_count, 0) + COALESCE(uc.comment_count, 0) + COALESCE(ul.like_count, 0) AS own_actions
    FROM
        users u
        LEFT JOIN (
            SELECT
                p.author_id,
                COUNT(c.id) AS comments_on_posts
            FROM
                posts p
                LEFT JOIN comments c ON c.post_id = p.id
            GROUP BY
                p.author_id) pc ON pc.author_id = u.id
        LEFT JOIN (
            SELECT
                p.author_id,
                COUNT(l.id) AS likes_on_posts
            FROM
                posts p
                LEFT JOIN likes l ON l.post_id = p.id
            GROUP BY
                p.author_id) pl ON pl.author_id = u.id
        LEFT JOIN user_posts up ON up.user_id = u.id
        LEFT JOIN user_comments uc ON uc.user_id = u.id
        LEFT JOIN user_likes ul ON ul.user_id = u.id
)
SELECT
    user_id,
    engagement_received,
    own_actions,
    CASE WHEN own_actions = 0 THEN
        NULL
    ELSE
        (engagement_received::decimal / own_actions)
    END AS engagement_index,
    RANK() OVER (ORDER BY (engagement_received::decimal / NULLIF (own_actions, 0)) DESC) AS rank
FROM
    engagement
ORDER BY
    engagement_index DESC;

