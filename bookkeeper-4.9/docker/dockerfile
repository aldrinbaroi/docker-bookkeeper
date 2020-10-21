FROM openjdk:8-jre-slim

ARG BOOKKEEPER_VERSION=4.9.2 
ARG SHORT_DISTRO_NAME=bookkeeper-$BOOKKEEPER_VERSION 
ARG DISTRO_NAME=bookkeeper-server-$BOOKKEEPER_VERSION-bin
ARG BK_HOME=/bookkeeper-server-$BOOKKEEPER_VERSION
ARG BK_SERVER_CONF=$BK_HOME/conf/bk_server.conf

ENV BOOKKEEPER_VERSION=$BOOKKEEPER_VERSION \
    BK_HOME=$BK_HOME \
    BOOKIE_PORT=3181 \
    USE_HOST_NAME_AS_BOOKIE_ID=true \
    USE_SHORT_HOST_NAME=true \
    BOOKIE_DEATH_WATCH_INTERVAL=1000 \
    EXTRA_SERVER_COMPONENTS= \
    HTTP_SERVER_ENABLED=false \
    HTTP_SERVER_PORT=8080 \
    HTTP_SERVER_CLASS=org.apache.bookkeeper.http.vertx.VertxHttpServer \
    JOURNAL_DIRECTORIES=/var/data/bookkeeper/journals \
    LEDGER_STORAGE_CLASS=org.apache.bookkeeper.bookie.SortedLedgerStorage \
    LEDGER_DIRECTORIES=/var/data/bookkeeper/ledgers \
    ZK_SERVERS=zk1:2181,zk2:2181,zk3:2181 \
    ZK_TIMEOUT=10000 \
    ZK_ENABLE_SECURITY=false \
    STORAGESERVER_GRPC_PORT=4181 \
    DLOG_BKC_ENSEMBLE_SIZE=3 \
    DLOG_BKC_WRITE_QUORUM_SIZE=2 \
    DLOG_BKC_ACK_QUORUM_SIZE=2 \
    STORAGE_RANGE_STORE_DIRS=/var/data/bookkeeper/ranges \
    STORAGE_SERVE_READONLY_TABLES=false \
    STORAGE_CLUSTER_CONTROLLER_SCHEDULE_INTERVAL_MS=30000 \
    ALLOW_STORAGE_EXPANSION=true \
    PATH=$PATH:$BK_HOME/bin 

# Add bookkeeper user
RUN set -eux \
    && groupadd -r bookkeeper \
    && useradd -r -g bookkeeper bookkeeper \ 
# Install required packges
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        dirmngr \
        gosu \
        gnupg \
        netcat \
        wget \
    && rm -rf /var/lib/apt/lists/* \
# Verify that gosu binary works
    && gosu nobody true \ 
# Download Apache BookKeeper, verify its PGP signature, untar and clean up
    && download() { \
        local f="$1"; shift; \
        local distFile="$1"; shift; \
        local success=; \
        local distUrl=; \
        for distUrl in \
            'https://www.apache.org/dyn/closer.cgi?action=download&filename=' \
            https://www-us.apache.org/dist/ \
            https://www.apache.org/dist/ \
            https://archive.apache.org/dist/ \
        ; do \
            if wget -O "$f" "$distUrl$distFile" && [ -s "$f" ]; then \
                success=1; \
                break; \
            fi; \
        done; \
        [ -n "$success" ]; \
    } \
    && download "$DISTRO_NAME.tar.gz" "bookkeeper/$SHORT_DISTRO_NAME/$DISTRO_NAME.tar.gz" \
    && download "$DISTRO_NAME.tar.gz.asc" "bookkeeper/$SHORT_DISTRO_NAME/$DISTRO_NAME.tar.gz.asc" \
    && download "$DISTRO_NAME.tar.gz.sha512" "bookkeeper/$SHORT_DISTRO_NAME/$DISTRO_NAME.tar.gz.sha512" \
    && sha512sum -c ${DISTRO_NAME}.tar.gz.sha512 \
    && export GNUPGHOME="$(mktemp -d)" \ 
    && wget https://dist.apache.org/repos/dist/release/bookkeeper/KEYS \
    && gpg --import KEYS \
    && gpg --batch --verify "$DISTRO_NAME.tar.gz.asc" "$DISTRO_NAME.tar.gz" \
    && tar -vzxf "$DISTRO_NAME.tar.gz" \
    && rm -rf "$GNUPGHOME" "$DISTRO_NAME.tar.gz" "$DISTRO_NAME.tar.gz.asc" "$DISTRO_NAME.tar.gz.sha512" "$BK_SERVER_CONF" \
    && mkdir -p "$JOURNAL_DIRECTORIES" \
    && mkdir -p "$LEDGER_DIRECTORIES" \
    && mkdir -p "$STORAGE_RANGE_STORE_DIRS" \
    && chown -R bookkeeper:bookkeeper "$BK_HOME" "$JOURNAL_DIRECTORIES" "$LEDGER_DIRECTORIES" "$STORAGE_RANGE_STORE_DIRS"

WORKDIR $BK_HOME 
EXPOSE 3181 8080 4181 
COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["bookkeeper","bookie"]
#::END::
