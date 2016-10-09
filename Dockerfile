FROM debian:jessie
#FROM resin/rpi-raspbian

ENV AMPACHE_VERSION 3.8.2

RUN apt-get update && \
    apt-get -y upgrade && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install \
        unzip git wget mysql-server \
        php5-cli php5-gd php5-curl php5-mysqlnd && \
    mkdir /opt/ampache && \
    groupadd -r ampache && useradd -r -g ampache ampache && \
    wget https://github.com/ampache/ampache/releases/download/${AMPACHE_VERSION}/ampache-${AMPACHE_VERSION}_all.zip \
        -O /tmp/ampache-${AMPACHE_VERSION}_all.zip && \
    unzip /tmp/ampache-${AMPACHE_VERSION}_all.zip -d /opt/ampache && \
    chown ampache:ampache /opt/ampache && \
    cp -rfd /opt/ampache/config/ /tmp/ampache_config && \
    rm /tmp/ampache-${AMPACHE_VERSION}_all.zip && \
    sed -i -E 's/upload_max_filesize = ([0-9]+)M/upload_max_filesize = 64M/g' /etc/php5/cli/php.ini && \
    sed -i -E 's/post_max_size = ([0-9]+)M/post_max_size = 64M/g' /etc/php5/cli/php.ini && \
    apt-get purge -y --auto-remove unzip wget && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt/ampache

COPY run.sh /run.sh

VOLUME ["/media", "/opt/ampache/config", "/var/lib/mysql"]

EXPOSE 8080

CMD /run.sh
