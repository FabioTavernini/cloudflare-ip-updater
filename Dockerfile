FROM alpine:3.20
LABEL org.opencontainers.image.source="https://github.com/FabioTavernini/cloudflare-ip-updater"

RUN apk add --no-cache bash curl jq

WORKDIR /app
COPY run.sh .
RUN chmod +x run.sh

CMD ["bash", "./run.sh"]
