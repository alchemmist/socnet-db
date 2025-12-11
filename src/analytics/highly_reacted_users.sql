-- Находим пользователей, у которых среднее число реакций на пост
-- значительно выше среднего по сети
WITH post_reactions AS (
    SELECT
        p.id AS post_id,
        p.author_id,
        COALESCE(c.comment_count, 0) + COALESCE(l.like_count, 0) AS total_reactions
    FROM
        posts p
        LEFT JOIN (
            SELECT
                post_id,
                COUNT(*) AS comment_count
            FROM
                comments
            GROUP BY
                post_id) c ON c.post_id = p.id
        LEFT JOIN (
            SELECT
                post_id,
                COUNT(*) AS like_count
            FROM
                likes
            GROUP BY
                post_id) l ON l.post_id = p.id
),
user_avg_reactions AS (
    SELECT
        author_id,
        AVG(total_reactions) AS avg_reactions
    FROM
        post_reactions
    GROUP BY
        author_id
),
network_avg AS (
    SELECT
        AVG(total_reactions) AS global_avg
    FROM
        post_reactions
)
SELECT
    u.id AS user_id,
    u.username,
    ua.avg_reactions,
    na.global_avg
FROM
    user_avg_reactions ua
    JOIN users u ON u.id = ua.author_id
    CROSS JOIN network_avg na
WHERE
    ua.avg_reactions > 1.5 * na.global_avg
ORDER BY
    ua.avg_reactions DESC;

