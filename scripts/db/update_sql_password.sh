#!/bin/bash

# Path to the .env file
ENV_FILE_PATH="./.env"

# Load environment variables from the .env file
if [ -f "$ENV_FILE_PATH" ]; then
    # Export each line of the .env file after removing any comments
    set -o allexport
    source "$ENV_FILE_PATH"
    set +o allexport
else
    echo "Error: .env file not found at $ENV_FILE_PATH"
    exit 1
fi

# Start the Docker container if it is not running
# docker-compose up -d

# Wait for a few seconds to ensure the database is fully started
sleep 5

# Execute the ALTER USER command inside the running PostgreSQL container
docker exec postgres_$ENV_NAME bash -c "psql -U postgres -c \"ALTER USER postgres WITH PASSWORD '$DB_PASSWORD';\""

# Check the exit status of the docker exec command
if [ $? -eq 0 ]; then
    echo "Password updated successfully."
else
    echo "Failed to update the password."
fi