#!/bin/sh

# ------------------------------ #
# Cloudflare DDNS Updater Script #
# ------------------------------ #

# Configuration
CLOUDFLARE_BASE_URL="https://api.cloudflare.com/client/v4"
CLOUDFLARE_API_TOKEN=""
CLOUDFLARE_DOMAIN_NAME=""
CLOUDFLARE_ZONE_ID=""


get_public_ip(){
    ip_providers="ifconfig.me api.ipify.org icanhazip.com"
    for ip_provider in ${ip_providers}; do 
        echo "Using ${ip_provider} to retrieve ip address"
        public_ip=$(curl --silent --max-time 10 --retry 3 "${ip_provider}")
        if [ $? -eq 0 ] && [ -n "${public_ip}" ]; then
            CURRENT_PUBLIC_IP=${public_ip}
            echo "Public IP Address: ${CURRENT_PUBLIC_IP}"
            return 0
        else
            echo "Unable to retrieve public ip address from ${ip_provider}"
        fi
    done
    echo "Unable to retrieve public ip address"
    exit 1
}

cloudflare_verify_token(){
    echo "Verifying Cloudflare token"
    response=$(curl --silent --max-time 10 --retry 3 "${CLOUDFLARE_BASE_URL}/user/tokens/verify" \
        -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}")
    success_status=$(echo "${response}" | jq -r '.success')
    if [ "${success_status}" != "true" ]; then
        echo "${response}" | jq -r '.errors'
        exit 1
    fi
    token_status=$(echo "${response}" | jq -r '.result.status')
    echo "API token is ${token_status}"
    if [ "${token_status}" != "active" ]; then
        echo "Check API token in Cloudflare account"
        exit 1
    fi
}

cloudflare_update_check(){
    response=$(curl --silent --max-time 10 --retry 3 "${CLOUDFLARE_BASE_URL}/zones/${CLOUDFLARE_ZONE_ID}/dns_records?name=${CLOUDFLARE_DOMAIN_NAME}" \
        -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" 
    )
    success_status=$(echo "${response}" | jq -r '.success')
    if [ "${success_status}" != "true" ]; then
        echo "${response}" | jq -r '.errors'
        exit 1
    fi
    cloudflare_stored_ip=$(echo "${response}" | jq -r '.result[0].content')
    if [ "${cloudflare_stored_ip}" == "${CURRENT_PUBLIC_IP}" ]; then
        echo "No record change required"
        exit 1
    fi
    echo "Record change required"
    CLOUDFLARE_DNS_RECORD_ID=$(echo "${response}" | jq -r '.result[0].id')
}

main(){
    CURRENT_PUBLIC_IP=""
    CLOUDFLARE_DNS_RECORD_ID=""
    get_public_ip
    cloudflare_verify_token
    cloudflare_update_check
}

main
