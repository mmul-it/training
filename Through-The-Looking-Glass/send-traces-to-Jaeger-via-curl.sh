#!/bin/bash

JAEGER_ENDPOINT="172.18.0.109:9411"

# Generate IDs (hex, 16 characters)
trace_id=$(hexdump -n 8 -e '"/%08X"' /dev/urandom | tr -d '/')
frontend_id=$(hexdump -n 8 -e '"/%08X"' /dev/urandom | tr -d '/')
backend_id=$(hexdump -n 8 -e '"/%08X"' /dev/urandom | tr -d '/')

# Current time in microseconds
end_ts=$(($(date +%s%N) / 1000))

# Generate random frontend duration between 400ms–800ms (in µs)
frontend_duration=$(( (RANDOM % 400000) + 400000 ))

# Frontend starts sometime before now (simulate processing time)
frontend_start=$(( ${end_ts} - ${frontend_duration} - 100000 ))

# Backend starts 100–300ms after frontend begins
backend_offset=$(( (RANDOM % 200000) + 100000 ))
backend_start=$(( ${frontend_start} + ${backend_offset} ))

# Backend duration between 200–600ms
backend_duration=$(( (RANDOM % 400000) + 200000 ))

# Send both spans in one trace
curl -X POST http://${JAEGER_ENDPOINT}/api/v2/spans \
  -H "Content-Type: application/json" \
  -d "[
    {
      \"traceId\": \"${trace_id}\",
      \"id\": \"${frontend_id}\",
      \"name\": \"frontend-request\",
      \"timestamp\": ${frontend_start},
      \"duration\": ${frontend_duration},
      \"localEndpoint\": { \"serviceName\": \"frontend-app\" },
      \"tags\": {
        \"component\": \"http-client\",
        \"span.kind\": \"client\",
        \"simulation\": \"randomized\"
      }
    },
    {
      \"traceId\": \"${trace_id}\",
      \"parentId\": \"${frontend_id}\",
      \"id\": \"${backend_id}\",
      \"name\": \"backend-processing\",
      \"timestamp\": ${backend_start},
      \"duration\": ${backend_duration},
      \"localEndpoint\": { \"serviceName\": \"backend-service\" },
      \"tags\": {
        \"component\": \"http-server\",
        \"span.kind\": \"server\",
        \"simulation\": \"randomized\"
      }
    }
  ]"

if [ $? -eq 0 ]; then
  echo "SUCCESS. Trace ${trace_id} sent to ${JAEGER_ENDPOINT}."
else
  echo "ERROR! Trace ${trace_id} NOT sent to ${JAEGER_ENDPOINT}!"
fi
