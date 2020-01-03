.. contents:: MISC Tips

=========
MISC Tips
=========

Unix - User friendly configuraiton tool
---------------------------------------

- AIX: smit
- HP-UX: sam

VMware - vSphere web service API
--------------------------------

Managed object browser: https://<vCenter or ESXi>/mob

VMware - Mount CD on ESXi
-------------------------

::

  vmkload_mod iso9660
  esxcfg-mpath -l | grep -i cd-room
  vsish -e set /vmkModules/iso9660/mount mpx.vmhbaX.C0:T0:L0
  ls /vmfs/volumes
  vsish -e set /vmkModules/iso9660/umount mpx.vmhbaX.C0:T0:L0

VMware - esxtop display
-----------------------

esxtop will display in batch mode by default for some terminal. To fix this, run it as below:

::

  TERM=xterm esxtop

VMware - esxtop configuration
-----------------------------

1. Make changes accordingly in the view
2. **W** to save the view as a new configuration
3. esxtop -c <conf> to load the view

VMware - esxtop metrics
-----------------------

Refer to below docs for meanings of each metrics:

- https://communities.vmware.com/docs/DOC-9279
- https://www.virten.net/vmware/esxtop

Docker - Mount nfs within a docker container
--------------------------------------------

.. code-block:: sh

   docker run --name <container name> -it  --privileged=true <image name, such as ubuntu:16.04>
   apt -qq update
   apt install nfs-common
   mount -t nfs <host>:<path> <mount point>

Docker - Enable Remote API
--------------------------

- Locate the service file: find /etc/systemd -iname "*docker*"
- Edit it and add **-H tcp://0.0.0.0:2376** as below:

   ::

     [Service]
     ExecStart=/usr/bin/dockerd -H fd:// -H tcp://0.0.0.0:2375

- Restart docker service: sudo systemctl daemon-reload; sudo systemctl restart docker.service
- Reference: https://docs.docker.com/engine/reference/commandline/dockerd/

Windows - Make an app always on top
-----------------------------------

1. Install AutoHotKey;
2. From the desktop (or any folder you want to put your AutoHotKey scripts)->New->AutoHotKey Script;
3. Add below contents:

   ::

     ^SPACE::  Winset, Alwaysontop, , A

4. Save the exit;
5. Click the script, then a icon for AutoHotKey will appear in your system tray;
6. Press 'Ctrl - SPACE' to toggle an app as always on top.

Windows - Shortcut for minimizing an app
----------------------------------------

- Some apps: Win - Down
- All apps: Alt - Space - n

OpenStack - Adding Security Group Rules to Allow ICMP and ssh
-------------------------------------------------------------

.. code-block:: sh

   neutron security-group-rule-create --direction egress --ethertype IPv4 --protocol tcp --port-range-min 1 --port-range-max 65535 --remote-ip-prefix 0.0.0.0/0 <security group id>
   neutron security-group-rule-create --direction egress --ethertype IPv4 --protocol icmp --remote-ip-prefix 0.0.0.0/0 <security group id>
   neutron security-group-rule-create --direction ingress --ethertype IPv4 --protocol tcp --port-range-min 1 --port-range-max 65535 --remote-ip-prefix 0.0.0.0/0 <security group id>
   neutron security-group-rule-create --direction ingress --ethertype IPv4 --protocol icmp --remote-ip-prefix 0.0.0.0/0 <security group id>

ELK - Deployment with Docker
------------------------------

1. Create a network for ELK components communications

   .. code-block:: sh

      docker network create elk

2. Start Elastic Search

   .. code-block:: sh

      docker run -d -p 9200:9200 -p 9300:9300 --network elk \
      -e "discovery.type=single-node" --hostname elasticsearch \
      --name elasticsearch docker.elastic.co/elasticsearch/elasticsearch:6.5.4

3. Start Kibana

   .. code-block:: sh

      docker run -d --name kibana --hostname kibana --network elk \
      -p 5601:5601 docker.elastic.co/kibana/kibana:6.5.4

4. Prepare LogStash Configuration(stdin and syslog as examples)

   .. code-block:: sh

      mkdir logstash_conf
      touch logstash_conf/logstash-stdin.conf
      # With below contents:
      # input { stdin {  }  }
      # output {
      #   elasticsearch { hosts => ["elasticsearch:9200"]  }
      #   stdout { codec => rubydebug  }
      # }
      touch logstash_conf/logstash-syslog.conf
      # With below contents(refer to https://www.elastic.co/guide/en/logstash/current/config-examples.html):
      # input {
      #   tcp {
      #     port => 5000
      #     type => syslog
      #   }
      #   udp {
      #     port => 5000
      #     type => syslog
      #   }
      # }
      #
      # filter {
      #   if [type] == "syslog" {
      #     grok {
      #       match => { "message" => "%{SYSLOGTIMESTAMP:syslog_timestamp} %{SYSLOGHOST:syslog_hostname} %{DATA:syslog_program}(?:\[%{POSINT:syslog_pid}\])?: %{GREEDYDATA:syslog_message}" }
      #       add_field => [ "received_at", "%{@timestamp}" ]
      #       add_field => [ "received_from", "%{host}" ]
      #     }
      #     date {
      #       match => [ "syslog_timestamp", "MMM  d HH:mm:ss", "MMM dd HH:mm:ss" ]
      #     }
      #   }
      # }
      #
      # output {
      #   elasticsearch { hosts => ["elasticsearch:9200"] }
      #   stdout { codec => rubydebug }
      # }
4. Start LogStash

   .. code-block:: sh

      docker run -d --rm --network elk \
      -v ~/logstash_conf:/usr/share/logstash/pipeline/ \
      -p 5044:5044 -p 9600:9600 -p 5000 \
      docker.elastic.co/logstash/logstash:6.5.4

5. Configure rsyslog to send logs to LogStash(Linux as the example)

   .. code-block:: sh

      echo '*.* @@<IP address of the host where elastic search is running>:5000' >> /etc/rsyslog.conf
      # @ for UDP, @@ for TCP. UDP does not work on Ubuntu 18.04 for unknown issues

6. Verification

   - Run command on the server who sends syslog to LogStash **logger 'test message 1'**
   - Verify with a browser accessing Kibana at **http://<Kibana host IP>:5601**

ELK - Develop New Beat
------------------------

While developing a new beat, there is a step to `fetch dependencies and set up the beat<https://www.elastic.co/guide/en/beats/devguide/current/setting-up-beat.html>`_.

The dedault Makefile does not work, it need to be changed as below:

::

  # Makefile: $GOPATH/src/github.com/elastic/beats/libbeat/scripts/Makefile
  ES_BEATS?=./vendor/github.com/elastic/beats
  VIRTUALENV_PARAMS?=-p /usr/bin/python2

ELK - Change Metricbeat Index Name
------------------------------------

Metricbeat will send events to indices named metricbeat-xxx. This leads to complication if multiple metricbeat sources exist. To avoid the problem, customized index name can be created as below. After making the changes, execute "metricbeat export config" to verify.

::

  # Edit /etc/metricbeat/metricbeat.yml and add below contents:
  output.elasticsearch:
    index: "vspheremetric-%{[agent.version]}-%{+yyyy.MM.dd}"
    indices:
      - index: "vspheremetric-%{[agent.version]}-%{+yyyy.MM.dd}"

  setup.template.name: "vspheremetric"
  setup.template.pattern: "vspheremetric-*"

PowerCLI - Integrate PowerCLI with PowerShell
---------------------------------------------

1. Uninstall previouslly installed PowerCLI;
2. Reinstall PowerCLI from PowerShell as a module:

   .. code-block:: sh

      # Run below commands from PowerShell
      Find-Module -Name VMware.PowerCLI
      # Install-Module -Name VMware.PowerCLI –Scope AllUsers
      Install-Module -Name VMware.PowerCLI –Scope CurrentUser
      Import-Module VMware.PowerCLI

3. PowerCLI can be used from PowerShell and PowerShell ISE now.

PowerCLI - Ignore Certification
-------------------------------

::

  Get-PowerCLIConfiguration
  Set-PowerCLIConfiguration -InvalidCertificateAction ignore

golang - Pass argument through pacakge flag in go test
------------------------------------------------------

1. Declare the arguments normally within the test code without calling flag.Parse():

   .. code-block:: go

      package hello

      import (
         "flag"
         "testing"
      )

      var name = flag.String("name", "", "Name to say hi to")

      func TestGenerateGoPackage(t \*testing.T) {
         t.Log(\*pkgdir)
      }

2. Pass arguments as below:

   .. code-block:: go

      go test -v hello.go -args -name "John Smith"

golang - Pass argument with dlv debug
--------------------------------------

::

  dlv debug <app>.go -- <param1> <param2> ...

golang - offline document
-------------------------

golang ships with offline document. But **godoc** need to be used to access them.

- Install godoc

  ::

    go get -v golang.org/x/tools/cmd/godoc

- Usage

  ::

    godoc -http=0.0.0.0:8080

golang - import
----------------

- Alias

  ::

    import <alias name> <package>

- Dot import: imports the package into the same namespace as the current package

  ::

    import . "math"
    fmt.Println(Pi)

- Blank import: init the package and stop compiling error

  ::

    import _ <package name>

golang - package init
----------------------

- init function

  Each source file can define an **init** function to set up corresponding requirements, and multiple init functions can exist within the same package. While such a package is imported, all init functions will be executed based on source file names.


  **init function signature**

  ::

    func init() {
      <code>
    }

- package initialization order

  - const will be initialized at first
  - var will be initialized then
  - all init functions will be called

golang - multiple expressions for switch case
----------------------------------------------

::

  switch letter {
  case "a", "b", "c":
    fmt.Println("case 1")
  default:
    fmt.Println("case 2")
  }

golang - triple dots/ellipsis
------------------------------

- Variadic function

  ::

    func Sum(nums ...int) int {
      res := 0
      for _, n := range nums {
          res += n
      }
      return res
    }

- Arguments to variadic functions

  ::

    primes := []int{2, 3, 5, 7}
    Sum(primes...)

- Array literals

  ::

    names := [...]string{"a", "b", "c"}

- Special go commands

  ::

    # tests all packages in the current directory and its subdirectories
    go test ./...

golang - iota
--------------

- The iota keyword represents successive integer constants 0, 1, 2, ...
- It resets to 0 whenever the word const appears in the source code
- It increments after each const specification
- Each source code file reset the value from beginning

**Examples:**

- Basic usage: the below 2 x forms are identical

  ::

    //C0, C1, C2 will be 0, 1, 2
    const (
      C0 = iota
      C1 = iota
      C2 = iota
    )

    const (
      C0 = iota
      C1
      C2
    )

- Start from non-zero

  ::

    //C0, C1, C2 will be 1, 2, 3
    const (
      C0 = iota + 1
      C1
      C2
    )

- Skip values

  ::

    //C0, C1, C2 will be 0, 2, 4
    const (
      C0 = iota
      -
      C1
      -
      C2
    )

golang - Silence complaints about the unused imports
-----------------------------------------------------

Complaints will be raised if a module is imported without usage. This are 2 x methods to supress this:

- Blank import: this is used mainly for package initialization, the init method will be executed

  ::

    import _ <pacakge name>

- Refer to some symbols with blank identifier: mainly used during debug

  ::

    import <pacakge name>
    var _ = <pacakge name>.<any symbol>

golang - Specify proxy for go commands
----------------------------------------

**go get** will fetch packages from their sources directly, such as from github.com, googlesource, etc. Such operations are expensive, and sometimes are even not possible (e.g., golang.org cannot be accessed from within China without a proxy). By enabling the go module feature and setting GOPROXY, packages can be retrieved more fast from a CDN like mirror.

  ::

    # export GO111MODULE=on
    export GO111MODULE=auto
    # export GOPROXY=https://goproxy.cn
    export GOPROXY=https://goproxy.io
    go get -u <package>

**Tips:** the same problem will be hit when build docker images for go apps. This can be worked around by setting ENV values in a dockerfile as below:

::

  FROM ......
  ENV GO111MODULE=on
  ENV GOPROXY=https://goproxy.io
  ......

Reference:

- `A Global Proxy for Go Modules <https://goproxy.io/>`_

golang - the replace directive with go module
-----------------------------------------------

**replace** directive allows to replace module/package dependencies with local copies or alternative repositories. It can be added before/after the require directive in go.mod

::

  replace github.com/user1/pkg1 => /local/dir/pkg1
  replace golang.org/google/pkg1 => github.com/google/pkg1

Beside the above mentioned method(edit go.mod) directly, below commands can also be leveraged for the same purpose:

::

  go mod edit -replace github.com/user1/pkg1=/local/dir/pkg1

golang - debug with delve
---------------------------

`Github Reference <https://github.com/go-delve/delve>`_


::

  # if dlv is executed from the directory where main.go is defined
  dlv debug
  # if dlv is run from other dirs
  dlv debug <package name>
  # pass parameters
  dlv debug -- -arg1 value1

golang - docs for builtin types and functions
-----------------------------------------------

::

  go doc builtin
  go doc builtin.<symbol>

golang - list packages
------------------------

- List packages under the workspace

  ::

    cd <workspace dir>
    go list ./...

- List all packages including packages from the std library and external libraries from the workspace

  ::

    go list ...

- List standard packages

  ::

    go list std

golang - list api of packages
------------------------------

List the full API of a package:

::

  # Locate the package/module name
  go list ...
  # Show the API
  go tool api <package|module>
  # Show the document for an object of the package/module
  go doc <package>[.<object>]

golang - techs to build docker image
--------------------------------------

The sample main.go as below is used for the show:

::

  package main

  import (
          "fmt"
          "time"
  )

  func main() {
          i := 0
          for {
                  i++
                  fmt.Printf("Hello World: %d\n", i)
                  time.Sleep(3 * time.Second)
          }
  }

- The straightforward build: the result docker image is over 350MB

  ::

    FROM golang:alpine
    RUN mkdir /app
    ADD . /app/
    WORKDIR /app
    RUN go build -o main .
    CMD ["./main"]

- Multistage build: the result docker image is about 8MB

  ::

    FROM golang:alpine as builder
    RUN mkdir /build
    ADD . /build/
    WORKDIR /build
    RUN go build -o main .

    FROM alpine
    COPY --from=builder /build/main /app/
    WORKDIR /app
    CMD ["./main"]

- Build from scratch: the result docker image is just about **2MB**

  ::

    FROM golang:alpine as builder
    RUN mkdir /build
    ADD . /build/
    WORKDIR /build
    RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -ldflags '-extldflags "-static"' -o main .
    FROM scratch
    COPY --from=builder /build/main /app/
    WORKDIR /app
    CMD ["./main"]

golang - go-micro registers service with an external consul deployment
------------------------------------------------------------------------

1. Start a consul daemon:

   ::

     docker run -d -p 8500:8500 --rm consul

2. Start a go microservice (leveraging go-micro) and register it to the consul:

   ::

     docker inspect <consul container> | grep IPAddress
     docker run -d -e MICRO_REGISTRY=consul -e MICRO_REGISTRY_ADDRESS=<consul container IP>:8500 --rm <go service image>

golang - type assert vs. type conversion
----------------------------------------

- Type assert only works for interface

  ::

    // i implements an interface
    t := i.(T)
    t, ok := i.(T)

- Type conversion is used to convert between varaible types

  ::

    a, b := 3, 10
    c := float32(a) / flat32(b)

- Type casting exists in go, but is rarelly used - ignore this
- Type switch is only a special switch statement

  ::

    // "type" is literal, no other word can be used;
    // i.(type) will trigger errors if it is not used with the switch statement;
    switch v := i.(type) {
    case T:
      // some ops
    case S:
      // some ops
    default:
      // some ops
    }
