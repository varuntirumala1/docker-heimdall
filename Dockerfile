FROM ghcr.io/linuxserver/baseimage-alpine-nginx:3.12

# set version label
ARG BUILD_DATE
ARG VERSION
ARG HEIMDALL_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="aptalca"

# environment settings
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2

RUN \
 echo "**** install runtime packages ****" && \
 apk add --no-cache --upgrade \
	curl \
	php7-ctype \
	php7-curl \
	php7-pdo_pgsql \
	php7-pdo_sqlite \
	php7-tokenizer \
	php7-zip \
	nano \
	supervisor \
	libc6-compat \
	tar \
 && curl -s -O https://bin.equinox.io/c/VdrWdbjqyF/cloudflared-stable-linux-amd64.tgz \
 && tar zxf cloudflared-stable-linux-amd64.tgz \
 && mv cloudflared /bin \
 && rm cloudflared-stable-linux-amd64.tgz \
 && echo "**** install heimdall ****" \
 && mkdir -p \
	/heimdall && \
 if [ -z ${HEIMDALL_RELEASE+x} ]; then \
	HEIMDALL_RELEASE=$(curl -sX GET "https://api.github.com/repos/linuxserver/Heimdall/releases/latest" \
	| awk '/tag_name/{print $4;exit}' FS='[""]'); \
 fi && \
 curl -o \
 /heimdall/heimdall.tar.gz -L \
	"https://github.com/linuxserver/Heimdall/archive/${HEIMDALL_RELEASE}.tar.gz" && \
 echo "**** cleanup ****" && \
 rm -rf \
	/tmp/*
# add supervisord configs and prep cloudflared
COPY supervisord.conf /etc/supervisord.conf
COPY argo-tunnel.sh /usr/share/argo-tunnel.sh
RUN chmod +x /usr/share/argo-tunnel.sh
# add local files
COPY root/ /

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
