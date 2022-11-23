.. contents:: MISC Tips

=========
MISC Tips
=========

Manual toc for restructuredText
---------------------------------

Section titles, footnotes, and citations automatically generate hyperlink targets (the title text or footnote/citation label is used as the hyperlink name).

::

  Title
  =======

  **TOC**

  - `header 1 title`_
  - `heder 2 title`_

  header 1 title
  ----------------

  header 2 title
  ----------------

Embed html color in restructuredText
---------------------------------------

::

  .. raw:: html

     <style>
     .red {color: red;}
     .blue {color: blue;}
     .green {color: green;}
     </style>

  .. role:: red
       :class: red

  .. role:: blue
      :class: blue

  .. role:: green
      :class: green

  Title
  ======

  html colored text:

  - :red:`this sentence will be shown in red`
  - :blue:`this sentence will be shown in blue`
  - :green:`this sentence will be shown in green`

Write Document with Sphinx
---------------------------

1. Install

   ::

     pip install sphinx

#. Create the project

   ::

     sphinx-quickstart

#. Add master doc (optional: it is required if readthedocs.org is used)

   ::

     # conf.py
     master_doc = 'index'

#. Generate PDF

   ::

     make latexpdf


#. To generate other contents, such as HTML

   ::

     make help
     make html

**Tips**:

- Use "figure" instead of "image" to provide more information

  * A figure can provides more information than an image including a caption and any other comment;
  * Refer to `RST and Sphinx Cheatsheet <https://thomas-cokelaer.info/tutorials/sphinx/rest_syntax.html>`_ for details;
  * Figures/images can be scaled with the *scale* option:

    ::

      .. figure:: images/demo.png
         :scale: 60%

         caption

         other comments

- Latex figure float alignment, default 'htbp' (here, top, bottom, page). Whenever an image does not fit into the current page, it will be 'floated' into the next page but may be preceded by any other text. To avoid this, define below section in sphinx project configuration:

  ::

    # conf.py
    latex_elements = {
      "figure_align": "H"
    }

- Add TODO support:

  * Enable the extension

    ::

      # conf.py
      extensions = ['sphinx.ext.todo']
      todo_include_todos = True

  * Usage:

    ::

      .. todo::

         hello world

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

Docker - Control terminal size for exec
-----------------------------------------

When "docker exec -it" is used to estabilish a terminal to the container, the terminal size (columns x lines) sometimes is quite small for content display.

::

  # Get the columns and lines of the current terminal
  tput cols
  tput lines
  # Establish a terminal to a container with the same terminal size as the current one
  docker exec -it -e COLUMNS=<tput cols output> -e LINES=<tput lines output> <container_name> bash

Windows - Shortcuts
----------------------------------------

- Minimize an app:

  * Some apps: Win - Down
  * All apps: Alt - Space - n

- Move the active applicaiton to the left/right screen

  * Shift + Win + Left/Right

Windows - Make an app always on top
-----------------------------------

Leverage windows powertoys - https://github.com/microsoft/PowerToys

Windows - Show MPIO Paths
---------------------------

::

  # To get target port WWN information, fcinfo needs to be used
  # which can be downloaded from Microsoft official web site
  # PowerShell
  get-disk
  mpclaim -s -d
  mpclaim -s -d <Disk>

Windows - Disable Trim/Unmap
-------------------------------

When Trim/Unmap is enabled on Windows, quick format may take quite a long time for SAN LUNs.

::

  fsutil behavior set DisableDeleteNotify NTFS 1
  fsutil behavior query DisableDeleteNotify

Winows - DiskPart
------------------

**DiskPart** is the builtin tool for managing disks on Windows, which can be used for disk rescan, list, online/offline, etc.

- Rescan disks

  ::

    diskpart
    rescan

- List disks/volumes

  ::

    diskpart
    list disk
    list volume

- Show volume filesystem

  ::

    diskpart
    list volume
    # Select volume based on the ID gotten from "list volume"
    select volume 0
    filesystem

- Show disk attributes

  ::

    diskpart
    list disk
    # Select disk based on the ID gotten from "list disk"
    select disk 0
    attributes

Windows - sg3_utils
---------------------

sg3_utils is a tool set to send SCSI commands to devices. It supports Linux, **Windows**, Solaris, FreeBSD, etc.

The tool can be downloaded from http://sg.danny.cz/sg/sg3_utils.html

Windows - winsat
------------------

winsat is a builtin benchmark tool which supports CPU, memory, disk, etc. benchmarking.

- Disk benchmark

  ::

    winsat disk -drive g

Windows - fio
---------------

::

  .\fio.exe --name=job1 --filename=E\:\\test.data --size=2GB --direct=1 --rw=randrw --bs=4k --runtime=120 --numjobs=4 --time_based --group_reporting --verify=md5 --rate=10m,10m

Windows - Run commands in the background
-----------------------------------------

::

  $session = New-PSSession -cn localhost
  Invoke-Command -Session $session -ScriptBlock {
      for (;;) {
          Copy-Item -Path E:\io.data -Destination F:\io.data -Recurse;
          Get-FileHash -Path F:\io.data | Select-Object -Property Hash | Format-List | Out-File -Append E:\test.txt;
          Remove-Item -Path F:\io.data -Recurse;
          Start-Sleep -Seconds 3;
      }
  } -AsJob
  Disconnect-PSSession $session

Windows - Run powershell commands in the background through ssh
-----------------------------------------------------------------

OpenSSH server can be enabled on current Windows releases. It makes running cmd commands remotely possible. However, to run powershell commands, all commands need to be formated within one line and wrapped as 'powershell -command "xxx; xxx; ..."'

::

  powershell -command "$session = New-PSSession -cn localhost; Invoke-Command -AsJob -Session $session -ScriptBlock { for (;;) { Copy-Item -Path E:\io.data -Destination F:\io.data -Recurse; Get-FileHash -Path F:\io.data | Select-Object -Property Hash | Format-List | Out-File -Append E:\test2.txt; Remove-Item -Path F:\io.data -Recurse; Start-Sleep -Seconds 3;  }  }; Disconnect-PSSession $session"

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

SQL
----

- Order by

  ::

    select * from t_task oder by create_time asc;
    select * from t_task oder by create_time desc;

- Limit

  ::

    select * from t_task limit 10;
    select * from t_task oder by create_time asc limit 5;

PostgreSQL psql
-----------------

- Get help

  ::

    help
    \?
    \h

- List databases

  ::

    \list

- Switch to a database

  ::

    \c <DB name>

- Show schemas

  ::

    \dnS+
    SELECT schema_name FROM information_schema.schemata;

- Show current search path

  ::

    SHOW search_path;

- Set new search_path:

  ::

    # After specifying schemas in search_path, there is no need to
    # specify table as <schema name>.<table name> anymore, just use
    # <table name> is enough.
    SET search_path to <schema 1>[,<schema 2>[,...]];

- Control output format

  ::

    # Show only rows toggle
    \t

    # Toggle expand output
    \x

    # Toggle aligned/unaliged output
    \a

    # Wrap lone lines or set a fixed width
    \pset format wrapped
    \pset columns 20

- List tables

  ::

    # Show only tables under current search_path
    \dt
    # Below command show all tables
    \dt *.
    \dt *.*
    SELECT * FROM pg_catalog.pg_tables;
    SELECT table_name FROM information_schema.tables;

- List views

  ::

    \dv
    SELECT schemaname,viewname from pg_catalog.pg_views;

- Show colume names - below commands are equivalent

  ::

    \d <table name>
    \d+ <table name>
    SELECT COLUMN_NAME from information_schema.COLUMNS WHERE TABLE_NAME = '<table name>';

MySQL
------

- Show query results vertically

  ::

    select * from t_vm \G;

SQLite3
-------

- Change query result display mode

  ::

    .help
    .mode line
    select * from t_task limit 3;
