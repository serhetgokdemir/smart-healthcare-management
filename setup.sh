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
echo "[3/6] Running schema.sql..."
if ! psql -v ON_ERROR_STOP=1 -d "$DB_NAME" -f schema.sql; then
    echo ""
    echo "ERROR: schema.sql failed."
    exit 1
fi

echo ""
echo "[4/6] Running data.sql..."
if ! psql -v ON_ERROR_STOP=1 -d "$DB_NAME" -f data.sql; then
    echo ""
    echo "ERROR: data.sql failed."
    exit 1
fi

echo ""
echo "[5/6] Running queries.sql..."
if ! psql -v ON_ERROR_STOP=1 -d "$DB_NAME" -f queries.sql; then
    echo ""
    echo "ERROR: queries.sql failed."
    exit 1
fi

echo ""
echo "[6/6] Running indexing.sql..."
if ! psql -v ON_ERROR_STOP=1 -d "$DB_NAME" -f indexing.sql; then
    echo ""
    echo "ERROR: indexing.sql failed."
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