IMAGE_VERSION = latest
REGISTRY = netint
IMAGE = ${REGISTRY}/vpu-k8-device-plugin:${IMAGE_VERSION}

.PHONY: default build buildImage deploy undeploy upgrade dry-run
default: deploy

build:
	cd source && CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o netint-device-plugin main.go server.go

buildImage:
	@if [ -f source/netint-device-plugin ]; then\
		cp source/netint-device-plugin docker/plugin/;\
		cd docker/plugin && docker build -t ${IMAGE} .;\
		rm -f docker/plugin/netint-device-plugin;\
	fi
	@if [ ! -f source/netint-device-plugin ]; then\
		echo "Error: Missing NETINT Device Plugin";\
		echo "Please build the Device Plugin, then rebuild the image";\
	fi
deploy:
	helm install netint deploy/helm/netint
	helm install quadra deploy/helm/quadra
undeploy:
	helm uninstall netint
	helm uninstall quadra
upgrade:
	helm upgrade netint deploy/helm/netint
	helm upgrade quadra deploy/helm/quadra
dry-run:
	helm install netint deploy/helm/netint --dry-run
	helm install quadra deploy/helm/quadra --dry-run

