#!/bin/bash
set -e

docker-entrypoint.sh postgres &

until pg_isready -h localhost -U "$POSTGRES_USER"; do
  sleep 1
done

if [ "$LOAD_SAMPLE_DATA" = "true" ]; then
  psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f /docker-entrypoint-initdb.d/seed.sql
fi

wait
