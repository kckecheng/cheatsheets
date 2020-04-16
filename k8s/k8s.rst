.. contents:: Kubernetes Tips

Kubernetes
===========

RKE
---

Document
+++++++++

RKE: https://rancher.com/docs/rke/latest/en/

List availabel kubernetes version
++++++++++++++++++++++++++++++++++

::

  rke config --system-images --version -

Generate system images definition
++++++++++++++++++++++++++++++++++

::

  rke config --system-images --version <version>

The default kubectl config file
++++++++++++++++++++++++++++++++

rke will create a kubectl config file after k8s deployment with the name as **kube_config_cluster.yml**

::

  kubectl --kubeconfig=kube_config_cluster.yml <commands>


kubectl
--------

List all supported resource types
++++++++++++++++++++++++++++++++++

Reference: https://kubernetes.io/docs/reference/using-api/api-concepts/

::

  kubectl api-resources [--namespaced=<true|false>] [-o <wide|name>] [--verbs=<get|list|post|put|patch>]


List all existing resouces
+++++++++++++++++++++++++++

::

  kubectl get all --all-namespaces

Check config file
++++++++++++++++++

::

  kubectl config --kubeconfig=<config file name> view [--minify]

The default config file
++++++++++++++++++++++++

kubectl will leverage **~/.kube/config** as the default config file if it exists.

Create a CMD PO for debug purpose
++++++++++++++++++++++++++++++++++

::

  kubectl run -it <deployment name >--image=alpine -- sh
  exit
  kubectl get pods
  kubectl exec -it <the pod name> sh
