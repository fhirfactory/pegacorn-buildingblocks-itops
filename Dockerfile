# Ref: https://github.com/prometheus/alertmanager
# Prometheus alertmanager version - 0.22.2 - https://prometheus.io/download/
ARG ARCH="amd64"
ARG OS="linux"
FROM quay.io/prometheus/busybox-${OS}-${ARCH}:latest

COPY amtool /bin/amtool
COPY alertmanager /bin/alertmanager

# Create user and add to group
RUN addgroup prometheus
RUN adduser pegacorn --no-create-home --disabled-password --gecos "" -G prometheus

RUN mkdir -p /etc/alertmanager
RUN mkdir -p /alertmanager && \
    chown -R pegacorn:prometheus etc/alertmanager /alertmanager

USER pegacorn
EXPOSE 9093 5001
VOLUME     [ "/alertmanager" ]
WORKDIR    /alertmanager

ARG IMAGE_BUILD_TIMESTAMP
ENV IMAGE_BUILD_TIMESTAMP=${IMAGE_BUILD_TIMESTAMP}
RUN echo IMAGE_BUILD_TIMESTAMP=${IMAGE_BUILD_TIMESTAMP}

ENTRYPOINT [ "/bin/alertmanager" ]
CMD        [ "--config.file=/etc/alertmanager/alertmanager.yml", \
             "--storage.path=/alertmanager" ]
