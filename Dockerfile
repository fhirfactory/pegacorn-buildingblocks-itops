# Ref: https://github.com/prometheus/prometheus/blob/main/Dockerfile
# Prometheus version - 2.28.1 ( https://github.com/prometheus/prometheus/releases )
ARG ARCH="amd64"
ARG OS="linux"
FROM quay.io/prometheus/busybox-${OS}-${ARCH}:latest

COPY prometheus /bin/prometheus
COPY promtool /bin/promtool
COPY console_libraries/ /usr/share/prometheus/console_libraries/
COPY consoles/ /usr/share/prometheus/consoles/
COPY LICENSE /LICENSE
COPY NOTICE /NOTICE
COPY npm_licenses.tar.bz2 /npm_licenses.tar.bz2

# Create user and add to group
RUN addgroup prometheus
RUN adduser pegacorn --no-create-home --disabled-password --gecos "" -G prometheus

RUN mkdir -p /etc/prometheus
RUN ln -s /usr/share/prometheus/console_libraries /usr/share/prometheus/consoles/ /etc/prometheus/
RUN mkdir -p /prometheus && \
    chown -R pegacorn:prometheus etc/prometheus /prometheus

USER       pegacorn
EXPOSE     9090
VOLUME     [ "/prometheus" ]
WORKDIR    /prometheus

ARG IMAGE_BUILD_TIMESTAMP
ENV IMAGE_BUILD_TIMESTAMP=${IMAGE_BUILD_TIMESTAMP}
RUN echo IMAGE_BUILD_TIMESTAMP=${IMAGE_BUILD_TIMESTAMP}

ENTRYPOINT [ "/bin/prometheus" ]
CMD        [ "--config.file=/etc/prometheus/prometheus.yml", \
             "--storage.tsdb.path=/prometheus", \
             "--web.console.libraries=/usr/share/prometheus/console_libraries", \
             "--web.console.templates=/usr/share/prometheus/consoles" ]

