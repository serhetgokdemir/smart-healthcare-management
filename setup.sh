#!/bin/bash

set -euo pipefail

DB_NAME="smart_healthcare"

echo "----------------------------------------"
echo "Smart Healthcare Database Setup"
echo "----------------------------------------"

echo ""
echo "[1/6] Dropping old database if exists..."
dropdb --if-exists "$DB_NAME"

echo ""
echo "[2/6] Creating database..."
createdb "$DB_NAME"

echo ""
echo "[3/6] Running sql/schema.sql..."
if ! psql -X -v ON_ERROR_STOP=1 -P pager=off -d "$DB_NAME" -f sql/schema.sql; then
    echo ""
    echo "ERROR: sql/schema.sql failed."
    exit 1
fi

echo ""
echo "[4/6] Running sql/data.sql..."
if ! psql -X -v ON_ERROR_STOP=1 -P pager=off -d "$DB_NAME" -f sql/data.sql; then
    echo ""
    echo "ERROR: sql/data.sql failed."
    exit 1
fi

echo ""
echo "[5/6] Running sql/queries.sql..."
if ! psql -X -v ON_ERROR_STOP=1 -P pager=off -d "$DB_NAME" -f sql/queries.sql; then
    echo ""
    echo "ERROR: sql/queries.sql failed."
    exit 1
fi

echo ""
echo "[6/6] Running sql/indexing.sql..."
if ! psql -X -v ON_ERROR_STOP=1 -P pager=off -d "$DB_NAME" -f sql/indexing.sql; then
    echo ""
    echo "ERROR: sql/indexing.sql failed."
    exit 1
fi

echo ""
echo "----------------------------------------"
echo "Database setup completed successfully."
echo "Database name: $DB_NAME"
echo "----------------------------------------"

echo ""
echo "You can now connect using:"
echo "psql -d $DB_NAME"