FROM postgres:latest

RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    git \
 && rm -rf /var/lib/apt/lists/*

RUN pip3 install --break-system-packages uv psycopg2-binary

COPY src/ /docker-entrypoint-initdb.d/
COPY scripts/ /scripts/
COPY start.sh /usr/local/bin/start.sh

RUN chmod +x /usr/local/bin/start.sh
RUN chmod +x /scripts/gen-seed.py

ENV POSTGRES_DB=socnet
ENV POSTGRES_USER=admin
ENV LOAD_SAMPLE_DATA=false
ENV REGENERATE_SAMPLE_DATA=false

CMD ["/usr/local/bin/start.sh"]
