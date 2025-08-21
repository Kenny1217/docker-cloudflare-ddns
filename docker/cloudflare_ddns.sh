#!/bin/sh

# ------------------------------ #
# Cloudflare DDNS Updater Script #
# ------------------------------ #

# Configuration
CLOUDFLARE_BASE_URL="https://api.cloudflare.com/client/v4"
CLOUDFLARE_API_TOKEN=""
CLOUDFLARE_DOMAIN_NAME=""
CLOUDFLARE_ZONE_ID=""
CLOUDFLARE_DNS_RECORD_ID=""



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

main(){
    CURRENT_PUBLIC_IP=""
    get_public_ip

}

main
