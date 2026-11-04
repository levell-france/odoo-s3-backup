FROM alpine:3.24

RUN apk add --no-cache \
    curl \
    tzdata \
    unzip \
    ca-certificates \
    aws-cli

WORKDIR /app

COPY cmd.sh cmd.sh

CMD ["/bin/sh", "cmd.sh"]
