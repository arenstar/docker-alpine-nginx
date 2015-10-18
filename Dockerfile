FROM alpine:3.1

ENV NGINX_VERSION 1.9.5

RUN apk add --update pcre openssl pcre-dev openssl-dev make git curl g++
RUN cd /tmp && curl http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz | tar -xz

WORKDIR /tmp/nginx-${NGINX_VERSION}

RUN git clone -b 2.2 https://github.com/vkholodkov/nginx-upload-module
RUN git clone  https://github.com/masterzen/nginx-upload-progress-module

RUN ./configure \
    --prefix=/usr/share/nginx \
    --sbin-path=/usr/sbin \
    --conf-path=/etc/nginx/nginx.conf \
    --http-log-path=/var/log/nginx/access.log \
    --error-log-path=/var/log/nginx/error.log \
    --lock-path=/var/lock/nginx.lock \
    --pid-path=/run/nginx.pid \
    --with-threads \
    --with-pcre-jit \
    --with-ipv6 \
    --with-file-aio \
    --with-http_v2_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_ssl_module \
    --with-http_auth_request_module \
    --with-http_realip_module \
    --add-module=nginx-upload-module* \
    --add-module=nginx-upload-progress-module*

RUN make && make install

RUN apk del pcre-dev openssl-dev make git curl g++ && rm -rf /var/cache/apk/* /tmp/nginx-*

RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

VOLUME ["/var/cache/nginx"]
WORKDIR /

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
