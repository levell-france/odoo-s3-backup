FROM alpine:3.19

RUN apk add --no-cache curl tzdata unzip ca-certificates
RUN curl https://dl.min.io/client/mc/release/linux-amd64/mc \
  --create-dirs \
  -o /usr/local/bin/mc
RUN chmod +x /usr/local/bin/mc
WORKDIR /app
COPY cmd.sh cmd.sh
CMD /bin/sh cmd.sh
