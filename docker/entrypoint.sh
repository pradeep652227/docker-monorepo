#!/bin/sh

set -e

# Determine DB host and port
if [ -n "$DATABASE_URL" ]; then
  echo "DATABASE_URL found, parsing connection..."

  DB_HOST=$(echo "$DATABASE_URL" | sed -E 's|.*://[^@]*@([^:/?]*).*|\1|')
  DB_PORT=$(echo "$DATABASE_URL" | sed -E 's|.*://[^@]*@[^:/]*:([0-9]+).*|\1|')
  DB_PORT=${DB_PORT:-5432}

  echo "Detected remote DB at $DB_HOST:$DB_PORT"

  # Use psql to check remote DB readiness
  echo "Checking remote DB readiness using psql..."
  until psql "$DATABASE_URL" -c '\q' >/dev/null 2>&1; do
    echo "Waiting for remote Postgres to be ready..."
    sleep 2
  done

  echo "Remote Postgres is ready."

else
  echo "No DATABASE_URL provided. Assuming local Postgres on postgres:5432"

  DB_HOST="postgres"
  DB_PORT="5432"

  # Use pg_isready for local Postgres
  until pg_isready -h "$DB_HOST" -p "$DB_PORT"; do
    echo "Waiting for local Postgres at $DB_HOST:$DB_PORT..."
    sleep 2
  done

  echo "Local Postgres is ready."
fi

# Run Prisma migrations
echo "Running database migrations..."
bun run db:migrate-deploy

# Generate Prisma client
echo "Generating Prisma client..."
bun run db:generate

# Start your app
echo "Starting backend server..."
exec "$@"
