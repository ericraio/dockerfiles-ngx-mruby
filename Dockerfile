FROM alpine:latest
MAINTAINER youyo

ENV NGINX_SRC_VER=nginx-1.13.12
ENV MGX_MRUBY_VERSION=v1.20.2

ENV NGINX_CONFIG_OPT_ENV \
	--prefix=/usr/share/nginx \
	--sbin-path=/usr/local/sbin/nginx \
	--conf-path=/etc/nginx/conf/nginx.conf \
	--pid-path=/var/run/nginx.pid \
	--http-log-path=/var/log/nginx/access.log \
	--error-log-path=/var/log/nginx/error.log \
	--with-http_ssl_module \
	--with-http_v2_module \
	--with-http_realip_module \
	--with-http_addition_module \
	--with-http_geoip_module \
	--with-http_sub_module \
	--with-http_gunzip_module \
	--with-http_gzip_static_module \
	--with-http_random_index_module \
	--with-http_secure_link_module \
	--with-http_stub_status_module \
	--with-stream \
	--with-stream_realip_module \
	--with-stream_ssl_module \
	--with-stream_ssl_preread_module \
	--with-mail \
	--with-mail_ssl_module \
	--with-threads

RUN apk add --update --no-cache openssl-dev \
		pcre-dev \
		geoip-dev \
		git && \
	apk add --virtual build-dependencies \
		build-base \
		ruby-dev \
		ruby-rake \
		tar \
		wget \
		bison \
		perl && \
	git clone -b ${MGX_MRUBY_VERSION} https://github.com/matsumoto-r/ngx_mruby.git && \
	cd ngx_mruby && \
	sh build.sh && \
	make install && \
	cd / && \
	apk del build-dependencies && \
	rm -rf ngx_mruby /var/cache/apk/* && \
	ln -sf /dev/stdout /var/log/nginx/access.log && \
	ln -sf /dev/stderr /var/log/nginx/error.log

ADD ngx-mruby/hook /usr/share/nginx/hook
ADD ngx-mruby/conf/nginx.conf /etc/nginx/conf/nginx.conf

EXPOSE 80 443
CMD ["nginx", "-g", "daemon off;"]
