IMAGE_VERSION = latest
REGISTRY = netint
IMAGE = ${REGISTRY}/vpu-k8-device-plugin:${IMAGE_VERSION}

NODE := minikube
HOST_PATH := /files

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

deploy-netint:
	helm install netint deploy/helm/netint

deploy-quadra:
	helm install quadra deploy/helm/quadra --set "nodeSelector.hostname=${NODE},volumes.hostPath=${HOST_PATH}"

deploy: deploy-netint deploy-quadra

undeploy-netint:
	helm uninstall netint

undeploy-quadra:
	helm uninstall quadra

undeploy: undeploy-netint undeploy-quadra

upgrade-netint:
	helm upgrade netint deploy/helm/netint

upgrade-quadra:
	helm upgrade quadra deploy/helm/quadra --set "nodeSelector.hostname=${NODE},volumes.hostPath=${HOST_PATH}"

upgrade: upgrade-netint upgrade-quadra

dry-run:
	helm install netint deploy/helm/netint --dry-run
	helm install quadra deploy/helm/quadra --dry-run --set "nodeSelector.hostname=${NODE},volumes.hostPath=${HOST_PATH}"
