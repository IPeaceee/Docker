# ===== BUILD STAGE =====
FROM alpine:3.20 AS builder

ARG NGINX_VERSION=1.28.0

RUN apk add --no-cache \
    git gcc g++ make automake autoconf libtool pcre-dev pcre2-dev zlib-dev \
    openssl-dev yajl-dev curl-dev linux-headers wget

# --- Build libmodsecurity ---
RUN git clone --depth 1 https://github.com/SpiderLabs/ModSecurity /modsecurity \
    && cd /modsecurity \
    && git submodule update --init \
    && ./build.sh \
    && ./configure \
    && make -j$(nproc) \
    && make install

# --- Connector ---
RUN git clone --depth 1 https://github.com/SpiderLabs/ModSecurity-nginx.git /modsec-nginx

# --- Nginx source ---
RUN wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
    && tar zxvf nginx-${NGINX_VERSION}.tar.gz

WORKDIR /nginx-${NGINX_VERSION}

RUN ./configure --with-compat --add-dynamic-module=/modsec-nginx \
    && make modules

# ===== RUNTIME =====
FROM nginx:1.28.0-alpine

RUN apk add --no-cache libstdc++ yajl

# copy module
COPY --from=builder /nginx-1.28.0/objs/ngx_http_modsecurity_module.so /etc/nginx/modules/

# copy libmodsecurity
COPY --from=builder /usr/local/modsecurity/lib/libmodsecurity.so* /usr/lib/

# copy modsecurity config
RUN mkdir -p /etc/nginx/modsecurity
COPY --from=builder /modsecurity/modsecurity.conf-recommended /etc/nginx/modsecurity/modsecurity.conf
COPY --from=builder /modsecurity/unicode.mapping /etc/nginx/modsecurity/unicode.mapping

# Enable ModSecurity Blocking Mode
RUN sed -i 's/SecRuleEngine DetectionOnly/SecRuleEngine On/' /etc/nginx/modsecurity/modsecurity.conf

# Add a simple test rule for verification
RUN echo "SecRule ARGS:testparam \"test\" \"id:1234,deny,status:403,msg:'Test Rule Blocked'\"" >> /etc/nginx/modsecurity/modsecurity.conf

# load module
RUN echo "load_module modules/ngx_http_modsecurity_module.so;" > /etc/nginx/modules/modsecurity.conf

CMD ["nginx", "-g", "daemon off;"]
