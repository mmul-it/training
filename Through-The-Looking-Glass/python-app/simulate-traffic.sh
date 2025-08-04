#!/bin/bash

# Endpoint to call
FRONTEND="http://172.18.0.1:5000/"
BACKEND="http://172.18.0.1:5001/process"

echo "Starting traffic simulation..."

while true; do
  # Generate a random number of parallel requests between 1 and 20
  PARALLEL_REQUESTS=$((RANDOM % 10 + 1))

  # To simulate also direct calls to the BACKEND check if the random
  # number is even, and then call FRONTEND otherwise BACKEND
  [ $((PARALLEL_REQUESTS%2)) -eq 0 ] && ENDPOINT=$FRONTEND || ENDPOINT=$BACKEND
  echo "Doing $PARALLEL_REQUESTS parallel requests to $ENDPOINT..."

  # Start the traffic simulation
  for i in $(seq 1 $PARALLEL_REQUESTS); do
  curl -s "$ENDPOINT" > /dev/null &  # Make the request in the background
  done

  # Wait a second and then restart
  sleep 3  # Add a small delay between requests
done
