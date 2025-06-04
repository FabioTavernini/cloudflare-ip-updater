#!/bin/bash
set -e

# Check required env vars
if [[ -z "$TOKEN" || -z "$ZONE" || -z "$RECORD" ]]; then
    echo "Error: TOKEN, ZONE, and RECORD environment variables must be set"
    exit 1
fi

while true; do
    # Get public IP
    PUBLIC_IP=$(curl -s https://api.ipify.org/)

    # Headers
    AUTH_HEADER="Authorization: Bearer $TOKEN"
    CONTENT_TYPE_HEADER="Content-Type: application/json"

    # Get Zone ID
    ZONES_JSON=$(curl -s -H "$AUTH_HEADER" https://api.cloudflare.com/client/v4/zones)
    ZONE_ID=$(echo "$ZONES_JSON" | jq -r --arg zone "$ZONE" '.result[] | select(.name == $zone) | .id')

    # Get DNS Record
    RECORDS_JSON=$(curl -s -H "$AUTH_HEADER" https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records)
    DNS_RECORD=$(echo "$RECORDS_JSON" | jq -r --arg record "$RECORD" '.result[] | select(.name == $record)')

    CURRENT_IP=$(echo "$DNS_RECORD" | jq -r '.content')
    RECORD_ID=$(echo "$DNS_RECORD" | jq -r '.id')

    if [[ "$CURRENT_IP" == "$PUBLIC_IP" ]]; then
        echo "Same public IP: $PUBLIC_IP"
    else
        echo "Updating Cloudflare IP to: $PUBLIC_IP"

        PATCH_BODY=$(jq -n \
            --arg comment "Auto-updated public IP - bash" \
            --arg content "$PUBLIC_IP" \
            --arg name "$RECORD" \
            --argjson proxied "$(echo "$DNS_RECORD" | jq '.proxied')" \
            --argjson ttl "$(echo "$DNS_RECORD" | jq '.ttl')" \
            --arg type "$(echo "$DNS_RECORD" | jq -r '.type')" \
            '{
                comment: $comment,
                content: $content,
                name: $name,
                proxied: $proxied,
                ttl: $ttl,
                type: $type
            }')

        RESPONSE=$(curl -s -X PATCH \
            -H "$AUTH_HEADER" \
            -H "$CONTENT_TYPE_HEADER" \
            --data "$PATCH_BODY" \
            "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID")

        SUCCESS=$(echo "$RESPONSE" | jq -r '.success')

        if [[ "$SUCCESS" == "true" ]]; then
            echo "Updated Cloudflare IP successfully"
        else
            echo "Failed to update Cloudflare IP"
            echo "Response: $RESPONSE"
        fi

    fi

    sleep 300 #Wait 5 minutes until next try
done
