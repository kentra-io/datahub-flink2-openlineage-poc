#!/bin/bash

# Configuration for the Kafka REST Proxy
REST_PROXY_URL="http://localhost:8085" # Updated to use port 8085 as specified
TOPIC_NAME="lineage-test-topic-json"
MESSAGE_JSON='{"text": "Hello, World!"}'

echo "Publishing message using Kafka REST Proxy..."

# Construct the full JSON payload for the REST Proxy
# The 'records' array contains the messages to produce.
# Each message should have a 'value' field (and optionally 'key' and 'partition').
# We are embedding your MESSAGE_JSON directly into the 'value' field.
POST_DATA=$(cat <<EOF
{
  "records": [
    {
      "value": ${MESSAGE_JSON}
    }
  ]
}
EOF
)

# Send the JSON message via the REST Proxy using curl
# -X POST: Specifies the HTTP POST method
# -H "Content-Type: application/vnd.kafka.json.v2+json": Essential header to tell the REST Proxy
#    that you are sending JSON-formatted Kafka records (version 2).
# --data "${POST_DATA}": Provides the JSON payload to be sent as the request body.
# "${REST_PROXY_URL}/topics/${TOPIC_NAME}": The target URL for publishing to a topic.
curl -X POST \
     -H "Content-Type: application/vnd.kafka.json.v2+json" \
     --data "${POST_DATA}" \
     "${REST_PROXY_URL}/topics/${TOPIC_NAME}"

# Check the exit status of the curl command
if [ $? -eq 0 ]; then
  echo "Message published via Kafka REST Proxy successfully to topic '${TOPIC_NAME}'."
else
  echo "Failed to publish message via Kafka REST Proxy to topic '${TOPIC_NAME}'."
  exit 1
fi
