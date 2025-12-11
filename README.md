## Database for social network

Tablse: `users`, `posts`, `comments`, `likes`, `friendships`

Analytics requests:

1. Calculate the "engagement index" for each user: (comments + likes on his posts) / (his own actions), rank users.

2. Identify users whose average number of reactions to a post is significantly higher than the average on the network.

## Conceptual schema
![](attachments/conceptual-schema.png)

## Logical schema
```mermaid
erDiagram
    users {
        uuid id PK
        varchar(255) username "not null, unique"
        varchar(255) name
        varchar(255) surname
        varchar(255) email "not null, unique"
        timestamp created_at "not null, default: now()"
        date birth_date
    }
    
    friendships {
        uuid id PK
        uuid user_id FK "not null"
        uuid friend_id FK "not null"
        timestamp created_at "not null, default: now()"
    }
    
    posts {
        uuid id PK
        varchar(320) title "not null"
        text content "not null"
        uuid author_id FK "not null"
        timestamp created_at "not null, default: now()"
        integer views "not null, default: 0"
    }
    
    comments {
        uuid id PK
        text content "not null"
        uuid post_id FK "not null"
        uuid author_id FK "not null"
        timestamp created_at "not null, default: now()"
    }
    
    likes {
        uuid id PK
        uuid post_id FK "not null"
        timestamp created_at "not null, default: now()"
        uuid user_id FK "not null"
    }
    
    users ||--o{ posts : "user_posts"
    users ||--o{ friendships : "friendships_user1"
    users ||--o{ friendships : "friendships_user2"
    posts ||--o{ comments : "commented"
    users ||--o{ comments : "commented"
    posts ||--o{ likes : "liked"
    users ||--o{ likes : "post_like_user"
```
