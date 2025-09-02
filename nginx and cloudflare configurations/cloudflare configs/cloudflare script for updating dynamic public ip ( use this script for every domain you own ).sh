#!/bin/bash

# Cloudflare API credentials
API_TOKEN="your_cloudflare_api_token_here"
ZONE_ID="your_zone_id_here"
RECORD_NAME="your domain.com"

# Get current public IP
IP=$(curl -s https://api.ipify.org)

# Get DNS Record ID dynamically
RECORD_ID=$(curl -s -X GET \
    "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records?type=A&name=${RECO
    -H "Authorization: Bearer ${API_TOKEN}" \
    -H "Content-Type: application/json" | jq -r '.result[0].id')

# Update the DNS record
UPDATE=$(curl -s -X PUT \
    "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records/${RECORD_ID}" \
    -H "Authorization: Bearer ${API_TOKEN}" \
    -H "Content-Type: application/json" \
    --data "{\"type\":\"A\",\"name\":\"${RECORD_NAME}\",\"content\":\"${IP}\",\"ttl\":120

# Check result
if echo "$UPDATE" | grep -q '"success":true'; then
    echo "DNS updated successfully to $IP"
else
    echo "Update failed: $UPDATE"
fi
