#!/bin/bash
set -euo pipefail

SEED_FILE="/docker-entrypoint-initdb.d/03_seed.sql"
REQ_FILE="scripts/requirements.txt"
GEN_SCRIPT="scripts/gen-seed.py"
SCD_LOADER_FILE="/docker-entrypoint-initdb.d/04_scd2_loader.sql"
SCD_TEST_FILE="/docker-entrypoint-initdb.d/tests/test_scd2_update.sql"
EMAIL_VALIDATE_TRIGGER_FILE="/docker-entrypoint-initdb.d/02_email_validate_trigger.sql"

run_psql() {
    local sql_file="$1"
    psql -v ON_ERROR_STOP=1 -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" -f "${sql_file}"
}

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

run_psql "/docker-entrypoint-initdb.d/01_schema.sql"

[ "${USE_SCD2_VERSIONING}" = "true" ] && run_psql "${SCD_LOADER_FILE}"

[ "${EMAIL_VALIDATE_TRIGGER}" = "true" ] && run_psql "${EMAIL_VALIDATE_TRIGGER_FILE}"

[ "${LOAD_SAMPLE_DATA}" = "true" ] && run_psql "${SEED_FILE}"

[ "${USE_SCD2_VERSIONING}" = "true" ] && [ "${LOAD_SAMPLE_DATA}" = "true" ] && [ "${TEST_UPDATES_FOR_SCD}" = "true" ] && run_psql "${SCD_TEST_FILE}"

wait
