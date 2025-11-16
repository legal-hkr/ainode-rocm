FROM archlinux

# Install dependencies
RUN pacman -Syu --noconfirm && pacman -S --noconfirm nginx vim

# Create nginx config
RUN printf 'worker_processes 1;\n\ninclude modules.d/*.conf;\n\nevents {\n\tworker_connections 1024;\n}\n\nhttp {\n\tinclude sites-enabled/*;\n}\n' > /etc/nginx/nginx.conf

#RUN ln -sf /dev/stdout /var/log/nginx/access.log && ln -sf /dev/stderr /var/log/nginx/error.log

WORKDIR /etc/nginx

ENTRYPOINT ["nginx"]
CMD ["-g", "daemon off;"]
