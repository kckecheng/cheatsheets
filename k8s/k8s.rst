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

StorageClass with GlusterFS
----------------------------

`GlusterFS <https://www.gluster.org/>`_ is one of the most popular persistent storage solutions on Kubernetes. This section shares the steps to enable a StorageClass based on GlusterFS on CentOS 7(Other Linux distributions/versions follow a similar process).

**Prerequisites**: prepare at least 3 x Linux nodes, below is the configuration used in this section.

- Sync time with NTP (refer to the Linux Chrony tips);
- Stop firewall;
- Make sure each node has a separate block device, say "/dev/sdb";
- Assume Kubernetes is deployed with user "rke";
- Update /etc/hosts:

  ::

    192.168.56.181 k8scentos1
    192.168.56.182 k8scentos2
    192.168.56.183 k8scentos3

Configure Gluster
~~~~~~~~~~~~~~~~~~


1. Install GlusterFS server on all nodes:

   ::

     # Enable Gluster repo
     # Using a "Long Term Stable" release is recommended, such as 4.1
     sudo yum isntall centos-release-gluster41
     # Install GlusterFS server
     sudo yum install glusterfs-server
     gluster --version

#. Start the service:

   ::

     sudo systemctl enable glusterd
     sudo systemctl start glusterd

#. Form a Trusted Server Pool (TSP):

   ::

     # Probe the other two nodes from any node.
     # In this example, commands are run from k8scentos1
     sudo gluster peer probe k8scentos2
     sudo gluster peer probe k8scentos3
     sudo gluster peer status
     sudo gluster pool list

Configure Heketi
~~~~~~~~~~~~~~~~~~

`Heketi <https://github.com/heketi/heketi>`_ only needs to be installed on one node, "k8scentos1" is used in this section.

1. Configure user "rke" with passwordless sudo privilege:

   ::

     # /etc/sudoers
     rke ALL = (ALL) NOPASSWD:ALL

#. Download the latest binary from the `Heketi release page <https://github.com/heketi/heketi/releases>`_, say "heketi-v9.0.0.linux.amd64.tar.gz";
#. Install Heketi:

   ::

     tar -zxvf heketi-v9.0.0.linux.amd64.tar.gz
     sudo cp heketi/{heketi,heketi-cli} /usr/local/bin
     heketi --version
     heketi-cli --version

#. Create a system group and user:

   ::

     sudo groupadd --system heketi
     sudo useradd -s /sbin/nologin --system -g heketi heketi

#. Create configuration and data path:

   ::

     sudo mkdir -p /var/lib/heketi /etc/heketi /var/log/heketi
     sudo chown -R heketi:heketi /var/lib/heketi /etc/heketi /var/log/heketi

#. Tune configurations:

   ::

     sudo cp heketi/heketi.json /etc/heketi
     # Tune options based on the sample "heketi.json" under the templates directory
     # Verify: sudo cat /etc/heketi/heketi.json | jq "."

#. Generate SSH Keys:

   ::

     sudo ssh-keygen -f /etc/heketi/heketi_key -t rsa
     sudo chown heketi:heketi /etc/heketi/heketi_key*

#. Configure passwordless SSH access for user "rke":

   ::

     sudo ssh-copy-id -i /etc/heketi/heketi_key.pub rke@k8scentos1
     sudo ssh-copy-id -i /etc/heketi/heketi_key.pub rke@k8scentos2
     sudo ssh-copy-id -i /etc/heketi/heketi_key.pub rke@k8scentos3
     # Verify: sudo ssh -i /etc/heketi/heketi_key rke@k8scentos<1|2|3>

#. Create a systemd service for Heketi:

   ::

     # /etc/systemd/system/heketi.service
     [Unit]
     Description=Heketi Server
     Requires=network-online.target
     After=network-online.target

     [Service]
     Type=simple
     User=heketi
     Group=heketi
     Restart=on-failure
     WorkingDirectory=/var/lib/heketi
     ExecStart=/usr/local/bin/heketi --config=/etc/heketi/heketi.json

     [Install]
     WantedBy=multi-user.target

#. Start the service

   ::

     sudo systemctl enable heketi
     sudo systemctl start heketi
     sudo systemctl status heketi

#. Create Heketi topology file "/etc/heketi/topology.json" (refer to "heketi-topology.json" under the templates directory)
#. Load the topology file:

   ::

     # Secret is defined in /etc/heketi/heketi.json
     heketi-cli topology load --user admin --secret password --json=/etc/heketi/topology.json

#. Verify:

   ::

     # Secret is defined in /etc/heketi/heketi.json
     # heketi-cli --user admin --secret password cluster list
     # heketi-cli --user admin --secret password node list
     export HEKETI_CLI_SERVER=http://localhost:8080
     export HEKETI_CLI_USER=admin
     export HEKETI_CLI_KEY=password
     heketi-cli cluster list
     heketi-cli node list
     heketi-cli topology info

Configure StorageClass
~~~~~~~~~~~~~~~~~~~~~~~

1. Define Kubernetes secret resource for GlusterFS:

   ::

     # gluster-secret.yaml
     apiVersion: v1
     kind: Secret
     metadata:
       name: gluster-secret
       namespace: default
     type: "kubernetes.io/glusterfs"
     data:
       # echo -n "PASSWORD" | base64
       key: cGFzc3dvcmQ=

#. Create the secret:

   ::

     kubectl apply -f gluster-secret.yaml
     kubectl get secrets

#. Define StorageClass (refer to `Storage Clases Concept <https://kubernetes.io/docs/concepts/storage/storage-classes/>`_):

   ::

     # gluster-storageclass.yaml
     apiVersion: storage.k8s.io/v1
     kind: StorageClass
     metadata:
       name: gluster
     provisioner: kubernetes.io/glusterfs
     reclaimPolicy: Retain
     volumeBindingMode: Immediate
     parameters:
       resturl: "http://192.168.56.181:8080"
       # clusterid can be found from the output of command "heketi-cli cluster list"
       clusterid: "36ae31269beed6e83d95a88da08aafd7"
       restauthenabled: "true"
       restuser: "admin"
       secretName: "gluster-secret"
       secretNamespace: "default"
       volumetype: "replicate:3"
       volumenameprefix: "k8s"

#. Create StorageClass:

   ::

     kubectl apply -f gluster-storageclass.yaml
     kubectl get sc

Use StorageClass
~~~~~~~~~~~~~~~~~~

1. Define a PVC:

   ::

     # gluster-pvc1.yaml
     apiVersion: v1
     kind: PersistentVolumeClaim
     metadata:
       name: pvc1
     spec:
       storageClassName: gluster
       accessModes:
         - ReadWriteOnce
       resources:
         requests:
           storage: 1Gi

#. Define a POD which will use the PVC:

   ::

     # gluster-pod.yaml
     apiVersion: v1
     kind: Pod
     metadata:
       name: gluster-pod
       labels:
         name: gluster-pod
     spec:
       containers:
       - name: gluster-pod
         image: busybox
         command: ["sleep", "60000"]
         volumeMounts:
         - name: pv1
           mountPath: /usr/share/busybox
           readOnly: false
       volumes:
       - name: pv1
         persistentVolumeClaim:
           claimName: pvc1

#. Create PVCs and start PODs:

   ::

     kubectl apply -f gluster-pvc1.yaml
     kubectl apply -f gluster-pod.yaml
     kubectl get pvc/pvc1
     kubectl get pods/gluster-pod -o yaml
