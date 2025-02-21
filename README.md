# Kubernetes Support for NETINT VPU


  - [About](#about)
  - [Prerequisites](#prerequisites)
  - [Installations](#installations)
    - [Install from Source](#install-from-source)
    - [Install using pre-built containers](#install-using-pre-built-containers)
  - [Verify the Installation](#verify-the-installation)
  - [Configuration](#configuration)
    - [Using a different Docker image](#using-a-different-docker-image)
    - [Limit VPUs](#limit-vpus)
  - [Example](#example)


## About
The Kubernetes orchestration tool allows NETINT video transcoder devices to be managed as nodes. This section details the configuration and usage of NETINT video transcoder device with Kubernetes.

## Prerequisites

This document assumes the user has Kubernetes already installed and is fimilar with the setup, configuration and management of Kubernetes.

## Installations

There are two methods to install the device plugin: [Install from Source](Install-from-Source) or to [Install using pre-built containers](Install-using-pre-built-containers).

### Install from Source

Complie the NETINT k8 device plugin. This step requires Go to be installed.
```
make build
```
Create Docker image for k8s device plugin.
```
make buildImage
```
Install Docker image using helm, the k8s device plugin needs privileged mode.
```
make deploy         
```

### Install using pre-built containers

Install Docker image using helm, the k8s device plugin needs privileged mode.
```
make deploy-netinst
```

## Verify the Installation

After successfully deploy Docker image, add a tag of each K8s node to enable NETINT card using below command.
```
kubectl label nodes xxx netint-device=enable
```

Verify the device plugin has been successfully installed with the `kubectl get pods -n kube-system` command. You should find the netint-device-plugin-#####, pod running with ready 1/1 and status should be running. 

```
$ kubectl get pods -n kube-system
NAME                               READY   STATUS    RESTARTS        AGE
coredns-787d4945fb-jmmxn           1/1     Running   1 (3d19h ago)   3d20h
etcd-minikube                      1/1     Running   1 (3d19h ago)   3d20h
kube-apiserver-minikube            1/1     Running   1 (3d19h ago)   3d20h
kube-controller-manager-minikube   1/1     Running   1 (3d19h ago)   3d20h
kube-proxy-xk44j                   1/1     Running   1 (3d19h ago)   3d20h
kube-scheduler-minikube            1/1     Running   1 (3d19h ago)   3d20h
netint-device-plugin-t46v2         1/1     Running   0               29s
netint-pod-85dbcb69bb-5pp6q        1/1     Running   0               29s
storage-provisioner                1/1     Running   4 (3d19h ago)   3d20h
```

You can check how many cards have been detected by the plugin with the `kubectl describe nodes minikube` command. T4xx devices will show up as node resource under netint.ca/ASIC and Quadra devices will show up as a node resource under netint.ca/Quadra.

```
Allocatable:
  cpu:                12
  ephemeral-storage:  240406076Ki
  hugepages-1Gi:      0
  hugepages-2Mi:      0
  memory:             16006452Ki
  netint.ca/ASIC:     0
  netint.ca/Quadra:   3
  pods:               110
```

You can view what resources are being used currently under the same command.

```
Allocated resources:
  (Total limits may be over 100 percent, i.e., overcommitted.)
  Resource           Requests      Limits
  --------           --------      ------
  cpu                1250m (10%)   1 (8%)
  memory             2218Mi (14%)  4266Mi (27%)
  ephemeral-storage  0 (0%)        0 (0%)
  hugepages-1Gi      0 (0%)        0 (0%)
  hugepages-2Mi      0 (0%)        0 (0%)
  netint.ca/ASIC     0             0
  netint.ca/Quadra   1             1
Events:              <none>
```

## Configuration

### Using a Different Docker image

Each pod needs to have a container that at minimum has libxcoder installed in order to use the NETINT VPU cards. Optionally FFmpeg or Gstreamer can be installed.

> [!IMPORTANT]
> The default container that pulled from Docker Hub only has support for the Quadra VPUs.

Change the value of the `image` image parameter to use the desired image.

```yml
  containers:
  - name: netint-pod
    image: netint/quadra_ubuntu-24.04_ffmpeg:latest
```

### Limit VPUs

To limit the number of VPUs that are available in each pod, the value for `netint.ca/ASIC` for T4xx and the `netint.ca/Quadra` for Quadra can be adjusted to the desired amount.

```yml
resources:
  requests:
    memory: "128Mi"
    cpu: "500m"
    netint.ca/ASIC: 1
  limits:
    memory: "128Mi"
    cpu: "500m"
    netint.ca/ASIC: 1
  requests:
    memory: "128Mi"
    cpu: "500m"
    netint.ca/Quadra: 1
  limits:
    memory: "128Mi"
    cpu: "500m"
    netint.ca/Quadra: 1
```


## Example

### Static pod file

NETINT has provided an example yaml file in `example/pod-with-netint.yaml` that can be used as a reference design.

### Helm

Deploy pod with tools for Quadra VPUs:
```
make deploy-quadra NODE=miniqube HOST_PATH=/files
```
