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

Docker - Mount nfs within a docker container
--------------------------------------------

.. code-block:: sh

   docker run --name <container name> -it  --privileged=true <image name, such as ubuntu:16.04>
   apt -qq update
   apt install nfs-common
   mount -t nfs <host>:<path> <mount point>

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

ELK Stack - Deployment with Docker
----------------------------------

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

Elastic Beats - Develop New Beat
--------------------------------

While developing a new beat, there is a step to `fetch dependencies and set up the beat<https://www.elastic.co/guide/en/beats/devguide/current/setting-up-beat.html>`_.

The dedault Makefile does not work, it need to be changed as below:

::

  # Makefile: $GOPATH/src/github.com/elastic/beats/libbeat/scripts/Makefile
  ES_BEATS?=./vendor/github.com/elastic/beats
  VIRTUALENV_PARAMS?=-p /usr/bin/python2

Elastic Metricbeat - Change Index Name
--------------------------------------

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

golang - offline document
-------------------------

golang ships with offline document. But **godoc** need to be used to access them.

- Install godoc

  ::

    go get -v golang.org/x/tools/cmd/godoc

- Usage

  ::

    godoc -http=0.0.0.0:8080
