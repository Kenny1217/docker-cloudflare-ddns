FROM alpine:3.22

USER root

RUN addgroup -S cloudflare && \
    adduser -S -u 1001 -h /usr/local/cloudflare -s /bin/sh -G cloudflare cloudflare && \
    apk add --no-cache curl jq && \
    rm -rf /var/cache/apk*

COPY ,/cloudflare_ddns.sh /usr/local/cloudflare
RUN chmod +x /usr/local/cloudflare/cloudflare_ddns.sh

USER cloudflare

WORKDIR /usr/local/cloudflare

ENTRYPOINT [ ",/cloudflare_ddns.sh" ]
