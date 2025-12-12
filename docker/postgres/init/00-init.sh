#!/bin/bash
set -e

echo "=== Sonik PostgreSQL Initialization ==="
echo "Running migrations..."

# Run migrations in order
for migration in /migrations/*.sql; do
    if [ -f "$migration" ]; then
        echo "Running: $(basename $migration)"
        psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -f "$migration"
    fi
done

echo "=== All migrations complete ==="
