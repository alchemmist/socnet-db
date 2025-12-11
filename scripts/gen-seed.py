import uuid
import argparse
import random
from faker import Faker

fake = Faker()

parser = argparse.ArgumentParser(
    description="Generate SQL seed data for social network"
)
parser.add_argument(
    "--seed-file", type=str, default="src/seed.sql", help="Path to output SQL seed file"
)
parser.add_argument("--num-users", type=int, default=10, help="Number of users")
parser.add_argument("--num-posts", type=int, default=50, help="Number of posts")
parser.add_argument("--num-comments", type=int, default=50, help="Number of comments")
parser.add_argument("--num-likes", type=int, default=100, help="Number of likes")
parser.add_argument(
    "--num-friendships", type=int, default=5, help="Number of friendships"
)
args = parser.parse_args()

seed_file = args.seed_file
NUM_USERS = args.num_users
NUM_POSTS = args.num_posts
NUM_COMMENTS = args.num_comments
NUM_LIKES = args.num_likes
NUM_FRIENDSHIPS = args.num_friendships

users = []
posts = []
comments = []
likes = []
friendships = []

used_usernames = set()
used_emails = set()

# Users
for _ in range(NUM_USERS):
    uid = str(uuid.uuid4())

    username = fake.user_name()
    while username in used_usernames:
        username = fake.user_name()
    used_usernames.add(username)

    email = fake.email()
    while email in used_emails:
        email = fake.email()
    used_emails.add(email)

    name = fake.first_name()
    surname = fake.last_name()
    birth_date = fake.date_of_birth(minimum_age=13, maximum_age=80)

    users.append((uid, username, email, name, surname, birth_date))

# Posts
for _ in range(NUM_POSTS):
    pid = str(uuid.uuid4())
    author = random.choice(users)[0]
    title = fake.sentence(nb_words=6)
    content = fake.paragraph(nb_sentences=3)
    created_at = fake.date_time_this_decade()
    views = random.randint(0, 1000)
    posts.append((pid, title, content, author, created_at, views))

# Comments
for _ in range(NUM_COMMENTS):
    cid = str(uuid.uuid4())
    post_id = random.choice(posts)[0]
    author = random.choice(users)[0]
    content = fake.sentence(nb_words=10)
    created_at = fake.date_time_this_decade()
    comments.append((cid, content, post_id, author, created_at))

# Likes
like_pairs = set()
for _ in range(NUM_LIKES):
    while True:
        user_id = random.choice(users)[0]
        post_id = random.choice(posts)[0]
        pair = (user_id, post_id)
        if pair not in like_pairs:
            like_pairs.add(pair)
            break
    lid = str(uuid.uuid4())
    created_at = fake.date_time_this_decade()
    likes.append((lid, post_id, user_id, created_at))

# Friendships
friend_pairs = set()
while len(friend_pairs) < NUM_FRIENDSHIPS:
    u1, u2 = random.sample(users, 2)
    if u1[0] == u2[0]:
        continue
    pair = tuple(sorted([u1[0], u2[0]]))
    if pair not in friend_pairs:
        friend_pairs.add(pair)
        friendships.append(
            (str(uuid.uuid4()), pair[0], pair[1], fake.date_time_this_decade())
        )

# Write to seed.sql
with open(seed_file, "w") as f:
    f.write("-- Users\n\n")
    for u in users:
        f.write(
            f"""INSERT INTO users (id, username, email, name, surname, birth_date) 
VALUES ('{u[0]}', '{u[1].replace("'", "''")}', '{u[2].replace("'", "''")}', '{u[3].replace("'", "''")}', '{u[4].replace("'", "''")}', '{u[5]}')
ON CONFLICT (id) DO NOTHING;
"""
        )
    f.write("\n-- Posts\n\n")
    for p in posts:
        f.write(
            f"""INSERT INTO posts (id, title, content, author_id, created_at, views) 
VALUES ('{p[0]}', '{p[1].replace("'", "''")}', '{p[2].replace("'", "''")}', '{p[3]}', '{p[4]}', {p[5]})
ON CONFLICT (id) DO NOTHING;
"""
        )
    f.write("\n-- Comments\n\n")
    for c in comments:
        f.write(
            f"""INSERT INTO comments (id, content, post_id, author_id, created_at) 
VALUES ('{c[0]}', '{c[1].replace("'", "''")}', '{c[2]}', '{c[3]}', '{c[4]}')
ON CONFLICT (id) DO NOTHING;
"""
        )
    f.write("\n-- Likes\n\n")
    for l in likes:
        f.write(
            f"""INSERT INTO likes (id, post_id, user_id, created_at) 
VALUES ('{l[0]}', '{l[1]}', '{l[2]}', '{l[3]}')
ON CONFLICT (id) DO NOTHING;
"""
        )
    f.write("\n-- Friendships\n\n")
    for fship in friendships:
        f.write(
            f"""INSERT INTO friendships (id, user_id, friend_id, created_at) 
VALUES ('{fship[0]}', '{fship[1]}', '{fship[2]}', '{fship[3]}')
ON CONFLICT (id) DO NOTHING;
"""
        )

print(f"Seed data generated in {seed_file}")
