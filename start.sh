#!/bin/bash
set -euo pipefail

SEED_FILE="/docker-entrypoint-initdb.d/seed.sql"
REQ_FILE="scripts/requirements.txt"
GEN_SCRIPT="scripts/gen-seed.py"

if [ "${REGENERATE_SAMPLE_DATA}" = "true" ]; then
    uv run --with-requirements="${REQ_FILE}" \
        "${GEN_SCRIPT}" \
        --seed-file "${SEED_FILE}" \
        --num-users "${NUM_USERS}" \
        --num-posts "${NUM_POSTS}" \
        --num-comments "${NUM_COMMENTS}" \
        --num-likes "${NUM_LIKES}" \
        --num-friendships "${NUM_FRIENDSHIPS}"
fi

docker-entrypoint.sh postgres &

until pg_isready -h localhost -U "${POSTGRES_USER}" -d "${POSTGRES_DB}"; do
    sleep 1
done
sleep 1

if [ "${LOAD_SAMPLE_DATA}" = "true" ]; then
    psql -v ON_ERROR_STOP=1 -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" -f "${SEED_FILE}"
fi

wait
