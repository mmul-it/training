curl -v -H "Content-Type: application/json" \
  -s -X POST "http://172.18.0.104:8080/loki/api/v1/push" \
  --data-raw "{\"streams\": [{ \"stream\": { \"application\": \"manual\", \"level\": \"info\" }, \"values\": [ [ \"$(date +%s%N)\", \"Log sent using curl\" ] ] }]}"
