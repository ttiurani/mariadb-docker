FROM alpine:3.5
MAINTAINER timo.tiuraniemi@iki.fi
ENV MARIADB_VERSION 10.1.21-r0

ENV USER mysql
RUN adduser -D -u 1000 $USER 

# Mariadb client and server plus bash for docker-entrypoint.sh to properly work
RUN apk add --no-cache mariadb=$MARIADB_VERSION mariadb-client=$MARIADB_VERSION \
bash ca-certificates openssl tzdata

# Gosu installation from https://github.com/hegand/alpine/blob/master/Dockerfile
ENV GOSU_VERSION 1.10
RUN set -x \
    && apk add --no-cache --virtual .gosu-deps \
        dpkg \
    && dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
    && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch" \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true \
&& apk del .gosu-deps dpkg

RUN mkdir -p /app/mariadb && mkdir /app/mariadb-data && mkdir -p /var/run/mysqld
COPY docker-entrypoint.sh /app/mariadb
RUN chown -R $USER:$USER /app && chown $USER:$USER /var/run/mysqld
WORKDIR /app

ENTRYPOINT ["/app/mariadb/docker-entrypoint.sh", "--user=mysql", "--datadir=/app/mariadb-data", "--socket=/var/run/mysqld/mysqld.sock"]
