ARG  REPOSITORY_BASE=sudobmitch
FROM ${REPOSITORY_BASE}/base:scratch as base-scratch
FROM nginx:alpine

RUN apk add --no-cache \
      curl

# shadow is needed for fix-perm, and also to add the tty group
#RUN addgroup -S -g 5000 app \                           
# && adduser -D -S -s /sbin/nologin -G app -u 5000 app \
RUN apk add --no-cache shadow \
 && useradd -u 5000 -G tty app \
 && sed -i -e 's/^user /#user /' /etc/nginx/nginx.conf \
 && sed -i -e 's#^pid .*$#pid /var/log/nginx/nginx.pid;#' /etc/nginx/nginx.conf \
 && chown -R app:app /var/cache/nginx /var/log/nginx

COPY --from=base-scratch / /
COPY entrypoint.d/ /etc/entrypoint.d/
COPY healthcheck.d/ /etc/healthcheck.d/
COPY conf.d/ /etc/nginx/conf.d/
COPY --chown=app:app html/ /usr/share/nginx/html/
RUN  save-volume /usr/share/nginx/html

ENV RUN_AS="app"
ENTRYPOINT ["/usr/bin/entrypointd.sh"]
CMD [ "nginx", "-g", "daemon off;" ]
HEALTHCHECK CMD /usr/bin/healthcheckd.sh
USER app:app

