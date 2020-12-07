FROM alpine:3.12

RUN apk add --no-cache git

RUN wget https://github.com/fopina/confgen/releases/download/v0.1.0/confgen_linux_amd64 -O /usr/bin/confgen
RUN chmod +x /usr/bin/confgen

COPY formula.rb.tpl /etc/formula.rb.tpl
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
