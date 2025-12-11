FROM postgres:latest

RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    git \
 && rm -rf /var/lib/apt/lists/*

RUN pip3 install --break-system-packages uv psycopg2-binary faker

COPY src/ /docker-entrypoint-initdb.d/
COPY scripts/ /scripts/
COPY start.sh /usr/local/bin/start.sh

RUN chmod +x /usr/local/bin/start.sh
RUN chmod +x /scripts/gen-seed.py

ENV POSTGRES_DB=socnet
ENV POSTGRES_USER=admin
ENV LOAD_SAMPLE_DATA=false
ENV REGENERATE_SAMPLE_DATA=false
ENV TEST_UPDATES_FOR_SCD=false
ENV EMAIL_VALIDATE_TRIGGER=true

ENV NUM_USERS=10
ENV NUM_POSTS=50
ENV NUM_COMMENTS=50
ENV NUM_LIKES=100
ENV NUM_FRIENDSHIPS=5
ENV USE_SCD2_VERSIONING=false

CMD ["/usr/local/bin/start.sh"]
