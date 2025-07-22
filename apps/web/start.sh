#!/bin/sh

echo "Starting OpenCut Web Application..."

# Wait for database to be ready
echo "Waiting for database connection..."
until nc -z db 5432; do
  echo "Database is unavailable - sleeping"
  sleep 1
done
echo "Database is up - continuing"

# Run database migrations
echo "Running database migrations..."
cd /app/apps/web
bun run db:migrate

# Start the application
echo "Starting the application..."
exec bun server.js
