FROM postgres:latest

COPY src/ /docker-entrypoint-initdb.d/
COPY start.sh /usr/local/bin/start.sh

RUN chmod +x /usr/local/bin/start.sh

ENV POSTGRES_DB=socnet
ENV POSTGRES_USER=admin
ENV LOAD_SAMPLE_DATA=false

CMD ["/usr/local/bin/start.sh"]

