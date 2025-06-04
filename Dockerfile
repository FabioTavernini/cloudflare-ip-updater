FROM alpine:3.20

RUN apk add --no-cache bash curl jq

WORKDIR /app
COPY run.sh .
RUN chmod +x run.sh

CMD ["bash", "./run.sh"]