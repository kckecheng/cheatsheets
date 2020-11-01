.. contents:: Kubernetes Tips

Kubernetes
===========

kubectl
--------

JSONPath
~~~~~~~~~

Refer to `JSONPath Support <https://kubernetes.io/docs/reference/kubectl/jsonpath/>`_.

List all supported resource types
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Reference: https://kubernetes.io/docs/reference/using-api/api-concepts/

::

  kubectl api-resources [--namespaced=<true|false>] [-o <wide|name>] [--verbs=<get|list|post|put|patch>]


List all existing resources
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  # Show POD, service, daemonset, deployment, replicaset, statefulset, job, cronjobs
  kubectl get all [--all-namespaces|-A|-n <namespace name>] [--show-labels] [-o wide]
  # To show everything including configmaps, secrets, pvc, etc.
  kubectl api-resources --verbs=list --namespaced -o name \
    | xargs -n 1 kubectl get --show-kind --ignore-not-found -n <namespace name>

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

  kubectl logs pods/<pod name> -c <container name>

Show crash logs of a Pod
~~~~~~~~~~~~~~~~~~~~~~~~~

::

  kubectl logs --previous pods/<pod name> -c <container name>

Execute commands on containers of a Pod
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  kubectl exec -it pods/<pod name> -c <container name> [--] <command>

Start a temporary Pod for debug
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  kubectl run -it --rm --restart=Never alpine --image=alpine sh

Port Foward
~~~~~~~~~~~~~

Forward one or more local ports to a Pod.

::

  # kubectl help port-foward
  kubectl port-forward pod/<name> [--address 0.0.0.0] <local port>:<Pod port>
  curl http://localhost:<local port>

Delete a label
~~~~~~~~~~~~~~~~

::

  # Assume xxx/yyy has a label key1=...
  kubectl label xxx/yyy key1-

Use environment variables in a manifest
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Use **envsubst**:

#. Define a manifest file referring to environment variables

   ::

     # deployment.yaml
     ...
     spec:
       type: LoadBalancer
       loadBalancerIP: $LBIP
     ...

#. Define environment variables

   ::

     export LBIP="192.168.10.10"

#. Use envsubst together with kubectl

   ::

     envsubst < deployment | kubectl apply -f -

DNS query
~~~~~~~~~~~

Assume there is a service named www, to query its DNS records:

::

  # Start a pod to query the service
  kubectl run -it --rm --restart=Never busybox --image=busybox sh
  # Below commands are run from the Pod
  # Get FQDN suffix: the part after svc
  cat /etc/resolv.conf
  nslookup -type=A www.<namespace>.svc.<FQDN suffix>

Output:

- Service: return the cluster IP
- Headless Service: return all the endpoints

Drain a Node
~~~~~~~~~~~~~~

::

  kubectl get nodes
  kubectl drain <node name>
  # Resume scheduling on the node
  kubectl uncordon <node name>

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

Show Node Resource Utilization Summary
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  kubectl top node

kubeconfig
-----------

The default config file
~~~~~~~~~~~~~~~~~~~~~~~~

kubectl will leverage **~/.kube/config** as the default config file if it exists.

Specify kubeconfig file
~~~~~~~~~~~~~~~~~~~~~~~~

::

  export KUBECONFIG="path/to/kubeconfig"

Merge multiple kubeconfig file
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  export KUBECONFIG=path/to/config1:path/to/config2[:<...>]
  kubectl config view --flatten | tee path/to/merged/config
  kubectl config get-contexts
  kubectl <...> --context=<context name>

Set default context
~~~~~~~~~~~~~~~~~~~~~

::

  kubectl config get-contexts
  kubectl config use-context <context name>
  kubectl config get-contexts

Extract a context
~~~~~~~~~~~~~~~~~~

::

  kubectl config view --context <context name> --minify --flatten | tee path/to/splited/config

helm
------

Repositories
~~~~~~~~~~~~~~

It is not quite efficient to access Helm default repositories from China, the below repositories can be used instead:

- http://mirror.azure.cn/kubernetes/charts
- http://mirror.azure.cn/kubernetes/charts-incubator
- https://charts.bitnami.com/bitnami
- https://apphub.aliyuncs.com

Hub
~~~~

- Default Hub : https://hub.helm.sh
- Kubeapps Hub: https://hub.kubeapps.com

Update Repos
~~~~~~~~~~~~~~~

::

  helm repo update

Search for Charts
~~~~~~~~~~~~~~~~~~

::

  helm search repo <pattern>

Show Chart Info
~~~~~~~~~~~~~~~~

::

  helm show chart <chart name>
  helm show all <chart name> | pandoc -t plain
  helm show readme <chart name> | pandoc -t plain

Show Chart Values
~~~~~~~~~~~~~~~~~~~

::

  # Customize values after getting the values
  helm show values <chart name> > values.yaml

List All Installed Chart Releases
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  helm list -A

Show Release Info
~~~~~~~~~~~~~~~~~~~

::

  helm get all <release name> -n <name space>
  helm get manifest <release name> -n <name space>
  helm get values <release name> -n <name space>

Download a Chart
~~~~~~~~~~~~~~~~~

::

  helm pull <chart name> [--version <chart version>]
  tar -zxvf <chart name>-<chart version>.tgz

Dry Run to Capture Changes to Make
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To capture values, manifests, notes, etc.

::

  helm install --dry-run --debug <release name> <chart name or path> -f <values file>.yaml

Upgrade a Release
~~~~~~~~~~~~~~~~~~~

::

  helm upgrade -f new-values.yml <release name> <chart name or path> [--version <chart version>]

Docker
--------

Container Registry Mirrors
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Container registry mirrors accelerate image usage. For details, refer to `this introduction <https://cloud.google.com/container-registry/docs/using-dockerhub-mirroring>`_.

Usage:

::

  # Add an option as below (for China) in /etc/docker/daemon.json
  {
    "registry-mirrors": ["https://registry.docker-cn.com"]
  }

Available registry mirrors in China:

- https://registry.docker-cn.com
- http://hub-mirror.c.163.com
- https://3laho3y3.mirror.aliyuncs.com
- http://f1361db2.m.daocloud.io
- https://mirror.ccs.tencentyun.com

Specify Insure Reigstries
~~~~~~~~~~~~~~~~~~~~~~~~~~~

To disregard security for registries (such as registries with self signed certs):

- If HTTPS is available but the certificate is invalid, ignore the error about the certificate;
- If HTTPS is not available, fall back to HTTP.

::

  {
    "insecure-registries" : ["192.168.10.10:9443", "myregistry1.example.local"]
  }

Build with multiple tags
~~~~~~~~~~~~~~~~~~~~~~~~~~

Multiple "-t" can be specified:

::

  docker build -t quay.io/kckecheng/powerstore_exporter:latest -t quay.io/kckecheng/powerstore_exporter:v1.1.0 .

Save and Load Images
~~~~~~~~~~~~~~~~~~~~~~

Docker images can be saved as a tar file:

::

  docker [image] save -o <file name>.tar <image 1 name/ID> [<image 2 name/ID> [...]]

The images packaged into a tar file can be loaded again:

::

  docker [image] load -i <file name>.tar

podman
~~~~~~~~

Podman is a daemonless container engine which can run in parallel with docker without leading to any conflict.

RKE
----

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

Not sure what is going on actually, a weird issue is hit:

- The Kubernetes is deployed successfully;
- Deployment and service can be created successfully;
- However, **a service can only be acceessed from the node where the pod is running**.

There are quite some other guys running into the same issue, however, no direct root cause is provided:

- https://github.com/kubernetes/kubernetes/issues/58908
- https://github.com/kubernetes/kubernetes/issues/70222
- https://github.com/kubernetes/kubernetes/issues/39823
- https://github.com/kubernetes/kubernetes/issues/42243

Below solution solves the problem:

- Disable iptables manipulation and IP masquerading for docker daemon:

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

- For RHEL/CentOS, the initial RAM disk image (initrd) needs to be rebuilt after disabling IPv6:

  ::

    dracut -f

- Delete the IPv6 localhost entry:

  ::

    # /etc/hosts
    # ::1 localhost localhost.localdomain localhost6 localhost6.localdomain6

- Specify NIC interface used for network:

  ::

    # RKE config.yml
    network:
      plugin: canal
      options:
        canal_iface: enp0s8
        canal_flannel_backend_type: udp # The default is vxlan, try "udp" when it does not work

- Done

K3s with MetalLB
-----------------

Provision a POC Kubernetes env with load balancer supported by MetalLB.

Provision Kubernetes
~~~~~~~~~~~~~~~~~~~~~~

::

  sudo k3s server --flannel-iface enp0s8 --node-external-ip 192.168.56.10 --docker --disable traefik --disable servicelb
  sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
  sudo chown a+r ~/.kube/config
  kubectl get all -n kube-system

Provision MetalLB
~~~~~~~~~~~~~~~~~~

Refer to https://metallb.universe.tf/installation for details.

::

  kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/namespace.yaml
  kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/metallb.yaml
  # On first install only - run directly afte the above 2 x commands, no need to wait for resource ready
  kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"

Configure MetalLB
~~~~~~~~~~~~~~~~~~

- Identify IP range should be used

  ::

    kubectl get nodes -o wide

- Configure load balancer IP range based on "EXTERNAL-IP" of nodes

  ::

    cat <<-EOF>metallb-configmap.yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      namespace: metallb-system
      name: config
    data:
      config: |
        address-pools:
        - name: default
          protocol: layer2
          addresses:
          - 192.168.56.50-192.168.56.99
    EOF
    kubectl apply -f metallb-configmap.yaml

Kubernetes POC Cluster with Kind
---------------------------------

Kind creates a POC Kubernetes cluster by leveraging containers (nodes are containers). Refer to https://kind.sigs.k8s.io for details.

::

  cat <<-EOF>kind-cluster.yaml
  kind: Cluster
  apiVersion: kind.x-k8s.io/v1alpha4
  nodes:
  - role: control-plane
    extraPortMappings:
    - containerPort: 80
      hostPort: 30080
      protocol: TCP
    - containerPort: 443
      hostPort: 30443
      protocol: UDP
    kubeadmConfigPatches:
    - |
      kind: JoinConfiguration
      nodeRegistration:
        kubeletExtraArgs:
          node-labels: "role=controller"
  - role: worker
    kubeadmConfigPatches:
    - |
      kind: JoinConfiguration
      nodeRegistration:
        kubeletExtraArgs:
          node-labels: "role=worker"
  - role: worker
    kubeadmConfigPatches:
    - |
      kind: JoinConfiguration
      nodeRegistration:
        kubeletExtraArgs:
          node-labels: "role=worker"
  EOF
  kind create cluster --config kind-cluster.yaml

API
----

Download OpenAPI Definitions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

1. Start the proxy: kubectl proxy --port=8080
#. Download API:

   ::

     curl http://localhost:8080/openapi/v2 > /tmp/raw.json

#. Reformat:

   ::

     cat /tmp/raw.json | jq '.' > swagger.json

Access API with CURL
~~~~~~~~~~~~~~~~~~~~~

1. Get the API endpoint:

   ::

     kubectl config view

#. Get the access token:

   ::

     kubectl get secrets
     kubectl describe secrets/<the secrete name>

#. Access API with CURL:

   ::

     curl -X GET <API Endpoint>/api --header "Authorization: Bearer <Secret Token>" --insecure

User Management
----------------

Service Account and Permission Assignment
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Refer to `Using RBAC Ahthorization <https://kubernetes.io/docs/reference/access-authn-authz/rbac/>`_ for the introductions on **Role**, **ClusterRole**, **RoleBinding** and **ClusterRoleBinding**.

- Define a service account and associated cluster role binding:

  ::

    # clusterrolebinding.yaml
    # Define service account
    ---
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: tester1
      namespace: default

    # Assign permissions by using cluster role binding
    ---
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRoleBinding
    metadata:
      name: clusterrole1
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: cluster-admin # Built-in cluster role
    subjects:
    -  kind: ServiceAccount
       name: tester1
       namespace: default

- Create objects:

  ::

    kubectl apply -f clusterrolebinding.yaml
    kubectl describe clusterrolebinding/clusterrole1
    kubectl describe sa/user1

- Define a service account and associated role binding:

  ::

    # rolebinding.yaml
    # Define a service account
    ---
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: tester2
      namespace: default

    # Define a role
    ---
    apiVersion: rbac.authorization.k8s.io/v1
    kind: Role
    metadata:
      name: role1
      namespace: default
    rules:
    - apiGroups: ["*"]
      resources: ["*"]
      verbs: ["*"]

    # Assign permissions by using role binding
    ---
    apiVersion: rbac.authorization.k8s.io/v1
    kind: RoleBinding
    metadata:
      name: role1
      namespace: default
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: Role
      name: role1
    subjects:
    - namespace: default
      kind: ServiceAccount
      name: tester2

- Create objects:

  ::

    kubectl apply -f rolebinding.yaml
    kubectl describe rolebinding/role1
    kubectl describe sa/user2

Generate Kubeconfig
~~~~~~~~~~~~~~~~~~~~

::

  kubeconfig_gen.sh tester1
  kubeconfig_gen.sh tester2

Check User Permissions
~~~~~~~~~~~~~~~~~~~~~~~

::

  kubectl auth can-i <list|create|edit|delete> <resource type>

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

#. Configure password less SSH access for user "rke":

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

#. Define a Pod which will use the PVC:

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

#. Create PVCs and start Pods:

   ::

     kubectl apply -f gluster-pvc1.yaml
     kubectl apply -f gluster-pod.yaml
     kubectl get pvc/pvc1
     kubectl get pods/gluster-pod -o yaml

etcd operations
----------------

Access etcd
~~~~~~~~~~~~~

::

  kubectl get nodes
  ssh <node where etcd is running>
  docker ps -a | grep etcd
  docker exec -it <etcd ID> sh
  etcdctl get / --prefix --keys-only

securityContext
-----------------

SecurityContext holds security configuration that will be applied to containers. Most of time, it does not need to be used. However, when some processes within a container are not run as "root", the object needs to be configured to avoid permission related issues.

- Problem Origination:

   - We want to run Prometheus on Kubernetes;
   - Without using PV/PVC, everything is fine;
   - When PV/PVC is used, "permission denied" will be triggered.

- Analysis:

  - Start a Prometheus Pod without using PV/PVC;
  - Start a shell session into the container of the Pod:

    ::

      kubectl exec -it pod/prometheus-pod001 -- sh

  - It is found processes within the container are started as "nobody":

    ::

      ~ $ ps -ef
      PID   USER     TIME  COMMAND
          1 nobody    0:00 /bin/prometheus --storage.tsdb.path=/prometheus --config.file=/etc/prometheus/prometheus.
         17 nobody    0:00 sh
         27 nobody    0:00 ps -ef

  - Since the process "/bin/prometheus" is started as "nobody", it must have access to directory "/prometheus";
  - But when a PV is mounted to the directory, it is owned by root by default and "nobody" won't have access;
  - Hence "permission denied" will be triggered.

- Solution:

  - Find the uid and gid which is used to started the processes:

    ::

      ~ $ id
      uid=65534(nobody) gid=65534(nogroup)

  - Define the securityContext (within the Pod spec section) as below based on the uid and gid we get as above:

    ::

      securityContext:
        runAsNonRoot: true
        runAsUser: 65534
        fsGroup: 65534

  - Prometheus + PV/PVC can be used smoothly now.

Spark on Kubernetes
--------------------

Service Account
~~~~~~~~~~~~~~~~

The default service account does not have enough permissions to launch executors (`documented as a prerequisite <https://spark.apache.org/docs/latest/running-on-kubernetes.html#prerequisites>`_).

**Solution**

::

  kubectl create serviceaccount spark
  kubectl create clusterrolebinding spark-role --clusterrole=edit --serviceaccount=default:spark --namespace=default
  ./bin/spark-submit <options> --conf spark.kubernetes.authenticate.driver.serviceAccountName=spark <app jar | python file | R file> [app arguments]
