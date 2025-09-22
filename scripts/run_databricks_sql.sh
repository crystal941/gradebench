#!/usr/bin/env bash
set -euo pipefail

# Requires env vars (or set them inline before calling):
#   DBSQLCLI_HOST_NAME, DBSQLCLI_HTTP_PATH, DBSQLCLI_ACCESS_TOKEN

need() { test -n "${!1:-}" || { echo "Missing env: $1"; exit 1; }; }
need DBSQLCLI_HOST_NAME
need DBSQLCLI_HTTP_PATH
need DBSQLCLI_ACCESS_TOKEN

run() {
  local file="$1"
  echo "==> Running $file"
  dbsqlcli \
    --hostname "$DBSQLCLI_HOST_NAME" \
    --http-path "$DBSQLCLI_HTTP_PATH" \
    --access-token "$DBSQLCLI_ACCESS_TOKEN" \
    -e "$file"
}

# quick ping
dbsqlcli \
  --hostname "$DBSQLCLI_HOST_NAME" \
  --http-path "$DBSQLCLI_HTTP_PATH" \
  --access-token "$DBSQLCLI_ACCESS_TOKEN" \
  -e "SELECT 1;"

run sql/00_init.sql
run sql/10_bronze_copy.sql          # uses TRUNCATE + COPY
run sql/20_silver_clean.sql
run sql/30_gold_analytics.sql

echo "All SQL executed ✔"
