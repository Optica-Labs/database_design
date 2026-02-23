#!/usr/bin/env bash
set -euo pipefail

# Upload SQL files from the repository to an Aurora (Postgres) cluster via psql.
# Usage (example):
#   AURORA_HOST=your.host.amazonaws.com AURORA_DB=dbname AURORA_USER=user PGPASSWORD=pass ./scripts/upload_to_aurora.sh

export PATH="${PATH}:/usr/local/bin"

if ! command -v psql >/dev/null 2>&1; then
  echo "psql not found in PATH. Install the Postgres client (psql) and retry." >&2
  exit 2
fi

: "${AURORA_HOST:?Please set AURORA_HOST}"
: "${AURORA_DB:?Please set AURORA_DB}"
: "${AURORA_USER:?Please set AURORA_USER}"
# PGPASSWORD should be exported or set in environment by caller

PORT="${AURORA_PORT:-5432}"
PSQL_OPTS=( -h "$AURORA_HOST" -p "$PORT" -U "$AURORA_USER" -d "$AURORA_DB" )

apply_files() {
  local pattern="$1" label="$2"
  shopt -s nullglob
  local files=( $pattern )
  shopt -u nullglob
  if [ ${#files[@]} -eq 0 ]; then
    echo "No $label files found (pattern: $pattern) — skipping."
    return
  fi

  echo "Applying $label files (${#files[@]})..."
  for f in "${files[@]}"; do
    echo "-- -> $f"
    psql "${PSQL_OPTS[@]}" -v ON_ERROR_STOP=1 -f "$f"
  done
}

echo "Host: $AURORA_HOST  DB: $AURORA_DB  User: $AURORA_USER  Port: $PORT"

apply_files "/Users/apeak/optica/database_design/sql/schemas/*.sql" "schema"
apply_files "/Users/apeak/optica/database_design/sql/views/*.sql" "views"
apply_files "/Users/apeak/optica/database_design/sql/migrations/*.sql" "migrations"
apply_files "/Users/apeak/optica/database_design/sql/queries/*.sql" "queries"
apply_files "/Users/apeak/optica/database_design/sql/sample_data/*.sql" "sample data"

echo "Done applying SQL files. If you have a large dump instead, use pg_restore/pg_dump workflow." 
