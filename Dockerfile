FROM docker.xlands-inc.com/baoyu/debian
MAINTAINER djluo <dj.luo@baoyugame.com>

ADD http://www.dotdeb.org/dotdeb.gpg /dotdeb.gpg
RUN export http_proxy="http://172.17.42.1:8080/" \
    && export DEBIAN_FRONTEND=noninteractive     \
    && apt-key add /dotdeb.gpg \
    && echo 'deb http://packages.dotdeb.org wheezy all' \
            > /etc/apt/sources.list.d/dotdeb.list \
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

ADD ./entrypoint.pl      /entrypoint.pl
ADD ./redis.conf         /redis/redis.conf

ENTRYPOINT ["/entrypoint.pl"]
CMD        ["/usr/bin/redis-server", "/redis/redis.conf"]
