# MISC Tips

## Principles

- SOLID ACID CAP
- LET'S USE RED
- Cats Donot Fear Mice.
- Puppies and little unicorns dance very merrily, playing in starry tents.
  - Puppies: parallel, scheduling, numa, locking, etc.
  - and: async, signals, interupts, softirqs, apic, preemption, etc.
  - little: limit, ulimit, cgroup, sysctl, etc.
  - unicorns: uptime, top, etc.
  - dance: dmesg, systemctl, journalctl, /var/log/messages, etc.
  - very: vmstat, free, /proc/meminfo, /sys, etc.
  - merrily: mpstat, /proc/interrupts, /proc/softirqs, etc.
  - playing: ps, pidstat, pstree, lsof, at, cron, /proc, /sys, etc.
  - in: iostat, netstat, ss, tcpdump, dstat, sysctl, etc.
  - starry: sar, top, atop, htop, perf top, etc.
  - tents: perf record, gdb, strace, trace-cmd, etc.
- Thoughtfully Create Really Excellent Inputs, ABI!:
  - Task/instruction
  - Context
  - References/examples
  - Evaluate
  - Iterate
  - Always be iterating
- Asking Thoughtfully Always Finds Clarity!:
  - Action verb as the staring point: summarize, analyze, translate, rewrite, extract, classify, generate, etc.
  - Topic/scope: be specific
  - Audience/tone: python program experts, 5th graders, friendly, formal, neutral, etc.
  - Format: as json string with fields ..., as table with columns ..., etc.
  - Constraints/rules: top K, should only mention ..., etc.

## Agile

- Stories: As a [type of user], I want to [action] so I can [goal].
- Roles: product owners, scrum masters, developers, testers, etc.
- Artifacts: product backlog, sprint backlog, increments(milestones), etc.
- Ceremonies: sprit planning, daily scrum, sprint review, sprint restrospective, etc.
- Rules:
  - Specific
  - Measurable
  - Achievable
  - Relevant
  - Time-bound

## Sphinx Markdown

1. Install

   ```bash
   pip install sphinx
   ```

2. Create the project

   ```bash
   sphinx-quickstart
   ```

3. Add master doc (optional: it is required if readthedocs.org is used)

   ```python
   # conf.py
   master_doc = 'index'
   ```

4. Generate PDF

   ```bash
   make latexpdf
   ```

5. To generate other contents, such as HTML

   ```bash
   make help
   make html
   ```

**Tips**:

- Use "figure" instead of "image" to provide more information
  - A figure can provides more information than an image including a caption and any other comment
  - Refer to [RST and Sphinx Cheatsheet](https://thomas-cokelaer.info/tutorials/sphinx/rest_syntax.html) for details
  - Figures/images can be scaled with the *scale* option:

    ```rst
    .. figure:: images/demo.png
       :scale: 60%

       caption

       other comments
    ```

- Latex figure float alignment, default 'htbp' (here, top, bottom, page). Whenever an image does not fit into the current page, it will be 'floated' into the next page but may be preceded by any other text. To avoid this, define below section in sphinx project configuration:

  ```python
  # conf.py
  latex_elements = {
    "figure_align": "H"
  }
  ```

- Add TODO support:
  - Enable the extension

    ```python
    # conf.py
    extensions = ['sphinx.ext.todo']
    todo_include_todos = True
    ```

  - Usage:

    ```rst
    .. todo::

       hello world
    ```

## RST: Manual TOC

Section titles, footnotes, and citations automatically generate hyperlink targets (the title text or footnote/citation label is used as the hyperlink name).

```rst
Title
=======

**TOC**

- `header 1 title`_
- `heder 2 title`_

header 1 title
----------------

header 2 title
----------------
```

## RST: Embed html color

```rst
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
```

## Diagram Scripting

- d2: https://d2lang.com/tour/intro/ && https://github.com/terrastruct/d2

## Docker

### Mount nfs within a docker container

```sh
docker run --name <container name> -it  --privileged=true <image name, such as ubuntu:16.04>
apt -qq update
apt install nfs-common
mount -t nfs <host>:<path> <mount point>
```

### Enable Remote API

- Locate the service file: find /etc/systemd -iname "*docker*"
- Edit it and add **-H tcp://0.0.0.0:2376** as below:

   ```
   [Service]
   ExecStart=/usr/bin/dockerd -H fd:// -H tcp://0.0.0.0:2375
   ```

- Restart docker service: sudo systemctl daemon-reload; sudo systemctl restart docker.service
- Reference: https://docs.docker.com/engine/reference/commandline/dockerd/

### Control terminal size for exec

When "docker exec -it" is used to estabilish a terminal to the container, the terminal size (columns x lines) sometimes is quite small for content display.

```bash
# Get the columns and lines of the current terminal
tput cols
tput lines
# Establish a terminal to a container with the same terminal size as the current one
docker exec -it -e COLUMNS=<tput cols output> -e LINES=<tput lines output> <container_name> bash
```

## Windows

### Show MPIO Paths

```powershell
# To get target port WWN information, fcinfo needs to be used
# which can be downloaded from Microsoft official web site
# PowerShell
get-disk
mpclaim -s -d
mpclaim -s -d <Disk>
```

### DiskPart

**DiskPart** is the builtin tool for managing disks on Windows, which can be used for disk rescan, list, online/offline, etc.

- Rescan disks

  ```cmd
  diskpart
  rescan
  ```

- List disks/volumes

  ```cmd
  diskpart
  list disk
  list volume
  ```

- Show volume filesystem

  ```cmd
  diskpart
  list volume
  # Select volume based on the ID gotten from "list volume"
  select volume 0
  filesystem
  ```

- Show disk attributes

  ```cmd
  diskpart
  list disk
  # Select disk based on the ID gotten from "list disk"
  select disk 0
  attributes
  ```

### sg3_utils

sg3_utils is a tool set to send SCSI commands to devices. It supports Linux, **Windows**, Solaris, FreeBSD, etc.

The tool can be downloaded from http://sg.danny.cz/sg/sg3_utils.html

### winsat

winsat is a builtin benchmark tool which supports CPU, memory, disk, etc. benchmarking.

- Disk benchmark

  ```cmd
  winsat disk -drive g
  ```

### Run commands in the background

```powershell
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
```

### Run powershell commands in the background through ssh

OpenSSH server can be enabled on current Windows releases. It makes running cmd commands remotely possible. However, to run powershell commands, all commands need to be formated within one line and wrapped as 'powershell -command "xxx; xxx; ..."'

```powershell
powershell -command "$session = New-PSSession -cn localhost; Invoke-Command -AsJob -Session $session -ScriptBlock { for (;;) { Copy-Item -Path E:\io.data -Destination F:\io.data -Recurse; Get-FileHash -Path F:\io.data | Select-Object -Property Hash | Format-List | Out-File -Append E:\test2.txt; Remove-Item -Path F:\io.data -Recurse; Start-Sleep -Seconds 3;  }  }; Disconnect-PSSession $session"
```

## SQL

- Order by

  ```sql
  select * from t_task oder by create_time asc;
  select * from t_task oder by create_time desc;
  ```

- Limit

  ```sql
  select * from t_task limit 10;
  select * from t_task oder by create_time asc limit 5;
  ```

- Delete table entries w/ events

```sql
DELIMITER //

USE db_kvm_comp
//

CREATE EVENT IF NOT EXISTS `cleanup_caseexecution`
ON SCHEDULE
  EVERY 1 WEEK
  STARTS CURRENT_TIMESTAMP + INTERVAL 1 HOUR
  ON COMPLETION PRESERVE
DO
BEGIN
  DELETE FROM `t_kvm_iot_caseexecution`
  WHERE end_time < NOW() - INTERVAL 30 DAY;
END;
//

CREATE EVENT IF NOT EXISTS `cleanup_report`
ON SCHEDULE
  EVERY 1 WEEK
  STARTS CURRENT_TIMESTAMP + INTERVAL 1 HOUR
  ON COMPLETION PRESERVE
DO
BEGIN
  DELETE FROM `t_kvm_iot_report`
  WHERE end_time < NOW() - INTERVAL 30 DAY;
END;
//


DELIMITER ;
```

## PostgreSQL psql

- Get help

  ```sql
  help
  \?
  \h
  ```

- List databases

  ```sql
  \list
  ```

- Switch to a database

  ```sql
  \c <DB name>
  ```

- Show schemas

  ```sql
  \dnS+
  SELECT schema_name FROM information_schema.schemata;
  ```

- Show current search path

  ```sql
  SHOW search_path;
  ```

- Set new search_path:

  ```sql
  # After specifying schemas in search_path, there is no need to
  # specify table as <schema name>.<table name> anymore, just use
  # <table name> is enough.
  SET search_path to <schema 1>[,<schema 2>[,...]];
  ```

- Control output format

  ```sql
  # Show only rows toggle
  \t

  # Toggle expand output
  \x

  # Toggle aligned/unaliged output
  \a

  # Wrap lone lines or set a fixed width
  \pset format wrapped
  \pset columns 20
  ```

- List tables

  ```sql
  # Show only tables under current search_path
  \dt
  # Below command show all tables
  \dt *.
  \dt *.*
  SELECT * FROM pg_catalog.pg_tables;
  SELECT table_name FROM information_schema.tables;
  ```

- List views

  ```sql
  \dv
  SELECT schemaname,viewname from pg_catalog.pg_views;
  ```

- Show colume names - below commands are equivalent

  ```sql
  \d <table name>
  \d+ <table name>
  SELECT COLUMN_NAME from information_schema.COLUMNS WHERE TABLE_NAME = '<table name>';
  ```

## MySQL

- Find a table based on its name

  ```sql
  select table_name from information_schema.tables where table_name like 't_host_%';
  ```

- Show query results vertically

  ```sql
  select * from t_vm \G;
  ```

- Dump specified tables from a database

  ```bash
  mysqldump -h192.168.100.10 -uroot -P3306 -p --column-statistics=0 db1 tab1 tab2 | tee tabledump.sql
  ```

- Load sql dump into another database

  ```bash
  mysql -h192.168.100.10 -uroot -P3306 -p --column-statistics=0 target_db1 < tabledump.sql
  ```

## SQLite3

- Show tables

  ```bash
  .schema
  ```

- Change query result display mode

  ```bash
  .help
  .mode column
  select * from t_task limit 3;
  ```
