#!/usr/bin/env bash
set -euo pipefail

# Requires env vars:
#   DBSQLCLI_HOST_NAME, DBSQLCLI_HTTP_PATH, DBSQLCLI_ACCESS_TOKEN

need() { test -n "${!1:-}" || { echo "Missing env: $1"; exit 1; }; }
need DBSQLCLI_HOST_NAME
need DBSQLCLI_HTTP_PATH
need DBSQLCLI_ACCESS_TOKEN

dbexec() {
  local file="$1"
  echo "==> Running $file"
  # join file into one string and pass to -e
  sql=$(cat "$file")
  dbsqlcli \
    --hostname "$DBSQLCLI_HOST_NAME" \
    --http-path "$DBSQLCLI_HTTP_PATH" \
    --access-token "$DBSQLCLI_ACCESS_TOKEN" \
    -e "$sql"
}

# sanity ping
dbsqlcli \
  --hostname "$DBSQLCLI_HOST_NAME" \
  --http-path "$DBSQLCLI_HTTP_PATH" \
  --access-token "$DBSQLCLI_ACCESS_TOKEN" \
  -e "SELECT current_catalog(), current_schema();"

dbexec sql/00_init.sql
dbexec sql/10_bronze_load.sql
dbexec sql/20_silver_clean.sql
dbexec sql/30_gold_analytics.sql

echo "All SQL executed ✔"
