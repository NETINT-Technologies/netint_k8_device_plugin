From alpine:latest
LABEL org.opencontainers.image.authors="NETINT Technologies" \
      io.k8s.display-name="NETINT VPU Device Plugin" \
      org.opencontainers.image.description="NETINT device plugin for Kubernetes"

#Should build netint plugin first
COPY netint-device-plugin /root/netint-device-plugin                                                                      

RUN apk update
#RUN DEBIAN_FRONTEND=noninteractive TZ=America/New_York apk -y install tzdata
RUN apk add nvme-cli udev

CMD ["/root/netint-device-plugin"]


