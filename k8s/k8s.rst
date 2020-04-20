.. contents:: Kubernetes Tips

Kubernetes
===========

RKE
---

Document
~~~~~~~~~

RKE: https://rancher.com/docs/rke/latest/en/

List availabel kubernetes version
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  rke config --system-images --version -

Generate system images definition
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  rke config --system-images --version <version>

The default kubectl config file
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

rke will create a kubectl config file after k8s deployment with the name as **kube_config_cluster.yml**

::

  kubectl --kubeconfig=kube_config_cluster.yml <commands>

Deployment pitfalls - 1
~~~~~~~~~~~~~~~~~~~~~~~~~

Not sure what is going on actually, a werid issue is hit:

- The Kubernetes is deployed successfully;
- Deployment and service can be created successfully;
- However, **a service can only be acceessed from the node where the pod is running**.

There are quite some other guys running into the same issue, however, no direct root cause is provided:

- https://github.com/kubernetes/kubernetes/issues/58908
- https://github.com/kubernetes/kubernetes/issues/70222
- https://github.com/kubernetes/kubernetes/issues/39823
- https://github.com/kubernetes/kubernetes/issues/42243

Below solution solves the problem:

- Disable iptables manuipulation and IP masquerading for docker daemon:

  ::

    #/etc/docker/daemon.json
    # restart docker service after the modification
    {
      "iptables": false,
      "ip-masq": false
    }

- Clean up existing iptables rules:

  ::

    # Accept all traffic
    iptables -F
    iptables -X
    iptables -t nat -F
    iptables -t nat -X
    iptables -t mangle -F
    iptables -t mangle -X
    iptables -t raw -F
    iptables -t raw -X
    iptables -t security -F
    iptables -t security -X
    iptables -P INPUT ACCEPT
    iptables -P FORWARD ACCEPT
    iptables -P OUTPUT ACCEPT

- Modify sysctl options

  ::

    # /etc/sysctl.conf
    net.bridge.bridge-nf-call-iptables=1
    net.ipv4.ip_forward=1
    # IPv6 must be disabled, not sure about the background reason
    net.ipv6.conf.all.disable_ipv6=1
    net.ipv6.conf.default.disable_ipv6=1

- Specify NIC interface used for network:

  ::

    # RKE config.yml
    network:
      plugin: canal
      options:
        canal_iface: enp0s8
        canal_flannel_backend_type: udp # The default is vxlan, try "udp" when it does not work

- Done

kubectl
--------

The default config file
~~~~~~~~~~~~~~~~~~~~~~~~

kubectl will leverage **~/.kube/config** as the default config file if it exists.


List all supported resource types
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Reference: https://kubernetes.io/docs/reference/using-api/api-concepts/

::

  kubectl api-resources [--namespaced=<true|false>] [-o <wide|name>] [--verbs=<get|list|post|put|patch>]


List all existing resouces
~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  kubectl get all --all-namespaces [--show-labels]

Check config file
~~~~~~~~~~~~~~~~~~

::

  kubectl config --kubeconfig=<config file name> view [--minify]

Check service
~~~~~~~~~~~~~~

- Get endpoints

  ::

    kubectl get endpoints[/<service name>]

- Get Cluster IP

  ::

    kubectl get svc/<service name> [-o <yaml|json|wide>]

Show containers of a Pod
~~~~~~~~~~~~~~~~~~~~~~~~~

::

  # Within the "Contains" section
  kubectl describe pods/<pod name>

Show logs of containers of a Pod
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  kubectl logs pors/<pod name> -c <container name>

Execute commands on containers of a Pod
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  kubectl exec -it pods/<pod name> -c <container name> [--] <command>

Create ConfigMap from CLI
~~~~~~~~~~~~~~~~~~~~~~~~~~

ConfigMap can be created by using yaml as other resources such as Deployment, Pod, etc. It can also be created from CLI directly.

- --from-file

  * From files

    ::

      # if key is not specified, the file name will be used as the key by default
      # file content will be used as values
      kubectl create configmap <name> --from-file[=][key=]<path to file1> --from-file[=][key=]<path to file2>

  * From directories:

    ::

      # all files under a directory will be used: file name will be used as keys, and file contents as values
      kubectl create configmap <name> --from-file=<path to directory1>

- --from-literal

  ::

    kubectl create configmap <name> --from-liternal=key1=value1 --from-literal=key2=value2

Rolling Update
~~~~~~~~~~~~~~~~

- Perform the udgrade

  * kubectl set image

    ::

      kubectl set image deployment/nginx nginx=nginx:1.9.1

  * kubectl edit

    ::

      kubectl edit deployment/nginx
      # Make the changes then exit

  * kubectl apply

    ::

      # Edit the deployment yaml
      vim nginx-deployment.yaml
      # Apply the change
      kubectl appy -f nginx-depliyment.yaml

- Check status

  ::

    kubectl rollout status deploy/nginx
    kubectl describe deploy/nginx

- Rollback

  ::

    kubectl rollout history deploy/nginx
    kubectl rollout history deploy/nginx --revision <X>
    kubectl rollout undo deploy/nginx [--to-revision=X]

- Pause/Resume

  ::

    # Usage: pasue the upgrade->make changes by editing yaml for multiple times->resume
    kubectl rollout pause deploy/nginx
    kubectl rollout resume deploy/nginx

MISC
-----

Container Registry Mirror
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Container registry mirrors accelerate image usage. For details, refer to `this introduction <https://cloud.google.com/container-registry/docs/using-dockerhub-mirroring>`_.

Usage:

::

  # Add an option as below (for China) in /etc/docker/daemon.json
  {
    "registry-mirrors": ["https://registry.docker-cn.com"]
  }
