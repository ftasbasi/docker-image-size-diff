FROM alpine:latest

RUN apk add --no-cache \
    bash \
    jq \
    yq \
    docker-cli

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh", "$REPO_LIST", "$OLD_RELEASE", "$NEW_RELEASE"]
