import argparse
import psycopg2
from pyvis import network as net_module
from pyvis.network import Network


def fetch_friendships(conn):
    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT u1.username, u2.username
            FROM friendships f
            JOIN users u1 ON f.user_id = u1.id
            JOIN users u2 ON f.friend_id = u2.id;
        """
        )
        return cur.fetchall()


def build_graph(friendships):
    net = Network(height="1000px", width="100%")

    import os

    template_path = os.path.join(
        os.path.dirname(net_module.__file__), "templates", "network.html"
    )
    net.template_path = template_path

    for u, v in friendships:
        net.add_node(u, label=u)
        net.add_node(v, label=v)
        net.add_edge(u, v)
    return net


def main():
    parser = argparse.ArgumentParser(
        description="Visualize friendships graph from PostgreSQL"
    )
    parser.add_argument("--host", default="localhost")
    parser.add_argument("--port", type=int, default=5432)
    parser.add_argument("--dbname", required=True)
    parser.add_argument("--user", required=True)
    parser.add_argument("--password", required=True)
    args = parser.parse_args()

    conn = psycopg2.connect(
        host=args.host,
        port=args.port,
        dbname=args.dbname,
        user=args.user,
        password=args.password,
    )

    friendships = fetch_friendships(conn)
    net = build_graph(friendships)
    net.show("friends.html", notebook=False)
    print("Graph generated: friends.html")


if __name__ == "__main__":
    main()
