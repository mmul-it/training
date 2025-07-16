#!/bin/bash

LOKI_ENDPOINT="http://172.18.0.104:8080"

curl -v -s -H "Content-Type: application/json" \
  -X POST "http://${LOKI_ENDPOINT}/loki/api/v1/push" \
  -d "[
    {
      \"streams\": [
        {
          \"stream\": { \"application\": \"manual\", \"level\": \"info\" },
          \"values\": [
            [ \"$(date +%s%N)\", \"Log sent using curl\" ]
          ]
        }
      ]
    }
  ]"
