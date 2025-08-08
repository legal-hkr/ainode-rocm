FROM debian:trixie-slim

RUN apt-get update && apt-get dist-upgrade -y && apt-get install --no-install-recommends -y build-essential curl git nginx vim

#RUN ln -sf /dev/stdout /var/log/nginx/access.log && ln -sf /dev/stderr /var/log/nginx/error.log

WORKDIR /etc/nginx

EXPOSE 80
EXPOSE 443

ENTRYPOINT ["nginx"]
CMD ["-g", "daemon off;"]
