FROM alpine:3.12

RUN apk update
RUN apk add \
    tini \
    ca-certificates \
    nginx \
    curl \
    libgcc \
    jq

ADD ./element-web/webapp /var/www
ADD ./conduit/target/armv7-unknown-linux-musleabihf/release/conduit /usr/local/bin/conduit
ADD ./docker_entrypoint.sh /usr/local/bin/docker_entrypoint.sh
RUN chmod a+x /usr/local/bin/docker_entrypoint.sh

WORKDIR /root

RUN mkdir /run/nginx

EXPOSE 8448 443

ENTRYPOINT ["/usr/local/bin/docker_entrypoint.sh"]
