FROM docker.xlands-inc.com/baoyu/debian
MAINTAINER djluo <dj.luo@baoyugame.com>

COPY ./preferences /etc/apt/preferences.d/redis
RUN export http_proxy="http://172.17.42.1:8080/" \
    && export DEBIAN_FRONTEND=noninteractive     \
    && echo 'deb http://ftp.cn.debian.org/debian sid main contrib' \
            >> /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y redis-server \
    && apt-get clean     \
    && mkdir /redis/     \
    && mkdir /redis/data \
    && mkdir /redis/logs \
    && unset http_proxy  \
    && unset DEBIAN_FRONTEND   \
    && rm -rf usr/share/locale \
    && rm -rf usr/share/man    \
    && rm -rf usr/share/doc    \
    && rm -rf usr/share/info   \
    && find var/lib/apt -type f -exec rm -fv {} \;

COPY ./entrypoint.pl      /entrypoint.pl
COPY ./redis.conf         /redis/redis.conf

ENTRYPOINT ["/entrypoint.pl"]
CMD        ["/usr/bin/redis-server", "/redis/redis.conf"]
