FROM alpine:3.20
LABEL org.opencontainers.image.source="https://github.com/FabioTavernini/cloudflare-ip-updater"
LABEL org.opencontainers.image.authors="https://github.com/FabioTavernini"
LABEL description="Auto update cloudflare DNS entry to your public facing IP"

RUN apk add --no-cache bash curl jq

WORKDIR /app
COPY run.sh .
RUN chmod +x run.sh

CMD ["bash", "./run.sh"]
