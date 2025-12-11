#!/bin/bash
set -e

docker-entrypoint.sh postgres &

until pg_isready -h localhost -U "$POSTGRES_USER"; do
  sleep 1
done

if [ "$REGENERATE_SAMPLE_DATA" = "true" ]; then
    uv run --with-requirements=scripts/requirements.txt scripts/gen-seed.py --seed-file /docker-entrypoint-initdb.d/seed.sql
fi

if [ "$LOAD_SAMPLE_DATA" = "true" ]; then
  psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f /docker-entrypoint-initdb.d/seed.sql
fi

wait
