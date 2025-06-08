#!/bin/sh

# Wait for the Postgres container to be ready
until pg_isready -h postgres -p 5432; do
  echo "Waiting for Postgres..."
  sleep 2
done

# Run Prisma migrations
bun run db:migrate-deploy

# Generate Prisma client
bun run db:generate

# Start your app
exec "$@"
