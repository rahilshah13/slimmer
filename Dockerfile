FROM alpine:latest AS builder

# overrideable example 
ARG APP_CMD="python3 -m http.server 8000"
ARG HEALTHCHECK_CMD="wget -qO- http://localhost:8000 > /dev/null 2>&1"

ENV APP_CMD="$APP_CMD"
ENV HEALTHCHECK_CMD="$HEALTHCHECK_CMD"
RUN apk update && apk add --no-cache strace findutils coreutils python3 wget
WORKDIR /app
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh
ENTRYPOINT ["/app/entrypoint.sh"]
