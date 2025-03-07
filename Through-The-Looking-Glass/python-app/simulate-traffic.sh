#!/bin/bash

# Endpoint to call
ENDPOINT="http://172.18.0.1:5000/"

echo "Starting traffic simulation..."

while true; do
  # Generate a random number of parallel requests between 1 and 20
  PARALLEL_REQUESTS=$((RANDOM % 50 + 1))
  echo "Doing $PARALLEL_REQUESTS parallel requests..."

  # Start the traffic simulation
  for i in $(seq 1 $PARALLEL_REQUESTS); do
  curl -s "$ENDPOINT" > /dev/null &  # Make the request in the background
  done

  # Wait a second and then restart
  sleep 1  # Add a small delay between requests
done
