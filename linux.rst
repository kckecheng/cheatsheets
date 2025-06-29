=======================
Command Line/Console
=======================

Command Editing Shortcuts
----------------------------

- Ctrl + a – go to the start of the command line
- Ctrl + e – go to the end of the command line
- Ctrl + b - move the cursor back one character
- Ctrl + f - move the cursor forward one character
- Ctrl + d - delete the character under cursor
- Ctrl + w – delete from cursor to start of word (i.e. delete backwards one word)
- Ctrl + k – delete from cursor to the end of the command line
- Ctrl + u – delete from cursor to the start of the command line
- Ctrl + y – paste word or text that was cut using one of the deletion shortcuts after the cursor
- Alt  + b – move backward one word (or go to start of word the cursor is currently on)
- Alt  + f – move forward one word (or go to end of word the cursor is currently on)
- Alt  + t – swap current word with previous
- Ctrl + t – swap character under cursor with the previous one
- Ctrl + backspace - delete a previous word (support path delimeter, such as /)

Command Recall Shortcuts
---------------------------

- Ctrl + r – search the history backwards
- Ctrl + s - search the history forward(xon needs to be turned off: stty -ixon)
- Ctrl + g - quite the search
- Ctrl + p – previous command in history (i.e. walk back through the command history)
- Ctrl + n – next command in history (i.e. walk forward through the command history)
- Ctrl + o - execute current displayed command(repeatable)
- Alt + . – use the last word of the previous command

Command Control Shortcuts
----------------------------

- Ctrl + l – clear the screen
- Ctrl + c – terminate the command
- Ctrl + z – suspend/stop the command
- Ctrl + s – freeze the terminal(stops the output to the screen)
- Ctrl + q – unfreeze the terminal(allow output to the screen)

Freeze/unfreeze the terminal
------------------------------

NOTE: some terminal may not react for the shortcuts due to xon/xoff value.

::

  stty -a | grep -E 'xon|xoff'
  # turn on
  stty ixon
  # turn off
  stty -ixon

- Ctrl + s - suspend/freeze the terminal, no input can be performed
- Ctrl + q - resume the terminal, input can be performed again

Console resize
---------------

When using virsh console or a tty connection to some equipment, the console size is small to show all the texts within a line. There are serveral ways to adjust this:

- xterm-resize(preferred): just run "resize"
- stty: stty rows 45 ; stty columns 140; stty size
- export LINES=45 && export COLUMNS=163

Show cursor icon
-------------------

Sometimes, the termianl cursor icon for current input position may get lost:

::

  tput cnorm

Use 256 colors terminal
-------------------------

::

  # anyone of below choices
  export TERM=xterm-256color
  export TERM=screen-256color
  export TERM=tmux-256color

Colour names
---------------

- Colours can be referred with names like "colourxxx";
- Frequent used 8 colors can also be referred as black, red, green, yellow, blue, magenta, cyan, white;
- Tool colortest(available on debian/ubuntu) can be used to show the effect of difference colors, e.g. colortest-8 to show effects of 8 colors when they are used as fg and bg;
- Builtin tput commands can be used to show colors:

  ::

    # man terminfo for references
    # setf/setb for 8 colors, setaf/setab(set ascii foreground/background) for 256 colors
    # foreground
    for c in {0..255}; do tput setaf $c; tput setaf $c | cat -v; echo =colour$c; done
    # background
    for c in {0..255}; do tput setab $c; tput setab $c | cat -v; echo =colour$c; done

List Shortcuts/Bindings
--------------------------

- sh/bash

  ::

    help bind
    bind -p
    bind -p | grep '^"\\C-'
    bind -p | grep '^"\\e'
    (\C-: Ctrl +, \e: meta/Alt +)

- zsh

  ::

    man zshzle
    bindkey -l
    bindkey -M <keymap name>
    bindkey -M emacs | grep '^"\^'
    bindkey -M emacs | grep -i '^"^\['

Long Command Edit/edit-command-line
--------------------------------------

 - export EDITOR='vim'
 - <Ctrl+x><Ctrl+e>
 - :wq

Change Line Editing Mode
---------------------------

- bash: set -o vi
- zsh : bindkey <-e|-v>

Command Quick Substitution
-----------------------------

- ^string1^string2^     - Repeat the last command, replacing string1 with string2. Equivalent to !!:s/string1/string2/
- !!gs/string1/string2/ - Repeat the last command, replacing all string1 with string2
- Refer to: https://www.gnu.org/software/bash/manual/bashref.html#History-Interaction

Special glob
-------------

::

  # 1. match files, directories and subdirectories
  # "*" matches all files and directories(without subdirectories);
  # "**" matches all files and directories and their subdirectories;
  # bash support
  shopt globstar
  shopt -s globstar
  # zsh support
  setopt extendedglob # prerequisite
  setopt GLOB_STAR_SHORT
  unset GLOB_STAR_SHORT
  # 2. respect/ignore case
  # bash support - no such function w/ bash
  # zsh support
  setopt extendedglob # prerequisite
  setopt CASE_GLOB
  unsetopt CASE_GLOB

=====================
Cutting Edge Tools
=====================

Modern Unix
-------------

A set of unix tools improving daily efficiency - https://github.com/ibraheemdev/modern-unix

pandoc
---------

a general markup converter supporting md, rst, etc.

::

  # convert to html
  pandoc -s -t html abc.rst -o abc.html
  # show in w3m
  pandoc <file name with suffix> | w3m -T text/html
  pandoc -s --toc <file name with suffix> [--metadata title=<title string>] | w3m -T text/html

ripgrep
----------

ripgrep is a line-oriented search tool that recursively searches your current directory for a regex pattern while respecting your gitignore(use **--no-ignore** to ignore those ignore files) rules. It is much more faster than any other tools, like grep, fd, etc.

::

  rg -e <pattern>
  rg -i -e <pattern>
  rg -F <fixed string>
  rg --no-ignore <pattern>

fzf
------

A command-line fuzzy finder, which integrates well with other tools.

::

  # Search history
  Ctrl + r
  # Change into a directory
  Alt  + c
  # Edit a file
  vim <path>/**<TAB>
  # Change into a directory
  cd  <path>/**<TAB>
  # Traverse the file system while respecting .gitignore
  rg -e <pattern> | fzf

fd
-----

fd is a simple, fast and user-friendly alternative to find. fd ignore files defined in .gitignore, to search files including such files, use option **--no-ignore**.

::

  fd <pattern>
  fd -F <pattern>
  fd -i <pattern>
  fd --no-ignore <pattern>

zoxide
---------

zoxide is a smarter cd command which remembers which directories are used frequently, and can help jump accordingly.

::

  # echo 'eval "$(zoxide init zsh)"' > ~/.zshrc
  # zoxide init zsh
  z foo<SPACE><TAB> 
  zi

delta
-------

A syntax-highlighting pager for git, diff, and grep output. Refer to https://github.com/dandavison/delta.

Usage: download the package from https://github.com/dandavison/delta/releases, then install and configure it by following its README.

bat
-----

an enhanced cat clone with syntax highlighting and Git integration.

::

  bat README.rst

tldr
-----

Simplified man pages.

::

  tldr tar
  tldr xargs

jq
-----

Reference:

- https://stedolan.github.io/jq/tutorial/
- https://programminghistorian.org/en/lessons/json-and-jq

**Exapmples**

::

  # validate if the conent of a document is a legal json string + pretty format
  cat <file name>.json | jq '.'
  # select objects based on field match - the output are separated json objects but not a single json list due to .[]
  tct_cli vpc eni list | jq -r '.[] | select(.NetworkInterfaceName | test("metaeni-80"))'
  # reverse the match
  tct_cli vpc eni list | jq -r '.[] | select(.NetworkInterfaceName | test("metaeni-80") | not)'
  # select multiple fields
  tct_cli vpc eni list | jq -r '.[] | select(.NetworkInterfaceName | test("metaeni-80")) | .NetworkInterfaceName, .NetworkInterfaceId'
  # output selected fields as csv - use jq -r to avoid \"
  tct_cli vpc eni list | jq -r '.[] | select(.NetworkInterfaceName | test("metaeni-80")) | [.NetworkInterfaceName, .NetworkInterfaceId] | @csv'
  # select only primary eni - the output is a single valid json list consists of json objects
  tct_cli vpc eni list | jq -r 'map(select(.name | match("Primary ENI")))'

atop
-----

atop is able to write output compressed as raw file and read them back later, hence it is a good choice for continuous monitoring in the background.

aria2
-------

A CLI based download manager supporting multiple threads.

::

  aria2c -x 16 -s 16 <the url to resource>

curlftpfs
------------

mount a ftp share as a normal file system:

::

  curlftpfs ftp://<site url> <mount point>

yq
-----

yq is similar as jq, but it is used to translate yaml/xml to json:

::

  cat <file name>.yaml | yq '.'

xmllint
---------

xmllint can be used to process xml with the help of "--xpath". Refer to https://www.w3schools.com/xml/xpath_syntax.asp for the syntax.

::

  cat vm.xml | xmllint --xpath "//vcpu/@cpuset" -

gpg
------

Encryp/decrypt a file.

::

  gpg -c <file>
  gpg -d <file>

busybox
-----------

BusyBox combines tiny versions of many common UNIX utilities into a single small executable. Since it provides binary download, it can be used on Unix/Linux based systems which do not support package instalaltion (scp busybox onto them and run directly).

Busybox ships with a large num. of applets (refer to `its document <https://busybox.net/downloads/BusyBox.html>`_ for details). Below is an example how to use busybox as a HTTP server:

::

  busybox httpd -p 0.0.0.0:8080 <html site root>
  pkill busybox

moreutils
------------

**moreutils** is a software package containing quite some useful tools can be leveraged during daily work.

- errno: list ERRNO and their short descriptions;
- ifdata: get NIC information, such as MTU, ip, etc., which can be used without further processing;
- combine: combine 2 x files together based on boolean operations;
- lckdo: run a program with a lock.

tshark
---------

Terminal based Wireshark.


::

  tshark --color -i eth0 -f "port 8080"
  tshark --color -i eth0 -d udp.port=4789,vxlan -c 3 -f "port 4789"
  tshark --color -V -i eth0

aichat
--------

AIChat is an all-in-one LLM CLI tool featuring Shell Assistant, CMD & REPL Mode, RAG, AI Tools & Agents, and More.

::

  cargo install aichat
  aichat --help
  aichat --info

fabric
---------

Simple tool for ai daily usage: https://github.com/danielmiessler/fabric. Since Moonshot API is compatible with OpenAI SDK, it can be used with fabric.

::

  fabric setup
  # use moonshot base url, say https://api.moonshot.cn/v1
  # use moonshot api key
  fabric -l
  echo "linux kernel mm struct" | fabirc -sp improve_prompt
  echo "go for loop usage" | fabric -sp explain_code

============
MISC Tips
============

hex editor
-----------

- hexedit: View and edit files in hexadecimal or in ASCII, especially useful for checking raw disk/file. Refer to https://github.com/pixel/hexedit
- ImHex: A Hex Editor for Reverse Engineers, Programmers. Refer to https://github.com/WerWolv/ImHex

Binary/raw data view/edit
---------------------------

Tools
~~~~~~

- xxd: hexdump or reverse
- hexdump: ASCII, decimal, hexadecimal, octal dump
- od: dump in octal, decimal, hexadecimal, integer, etc.
- hexedit: view and edit files in hex or ASCII, refer to https://github.com/pixel/hexedit

Examples
~~~~~~~~~

- Generate a random unsigned decimal 2-byte integer

  ::

    od -vAn -N2 -tu2 < /dev/urandom

- Search file content with a raw disk

  ::

    # hexdump -C can also be used
    # hexedit can also be used
    xxd /dev/sda | grep <ASCII string>

- Change file contents from a raw disk

  ::

    # man hexedit to find the commands supported by hexedit
    hexedit /dev/sdc

manpage toc
--------------

Based on the level of title you want to see, below commands can be used(3 stands for 3 x levels of titles).

::

  man ovs-vsctl | grep '^ \{0,3\}[A-Z]'

Auto start
------------

Run a script during system boot
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To run a script automatically during system boot, rc.local, bash profile, etc. can be leveraged. However, customized systemd service nowadays is much better for the same purpose.

1. Define a customized systemd service:

   - Create a plain text file under /etc/systemd/system as below, name it as route_add.service for example:

     ::

       [Unit]
       Description=Add customized ip routes
       After=network.service

       [Service]
       Type=oneshot
       ExecStart=/usr/local/bin/route_add.sh

       [Install]
       WantedBy=multi-user.target

   - Refer to manpage systemd.service and systemd.unit for the detailed explanations on each paramaters.

2. Create the actual script, such as /usr/local/bin/route_add.sh in our example, and assign exec permission with chmod a+x /usr/local/bin/route_add.sh
3. Enable and run it:

   ::

     systemctl enable route_add.service
     systemctl start route_add.service

Run a script during system boot and keep it running
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A service Type can be defined as oneshot, simple, forking, etc. When it is needed to keep a script running in the background forever, **forking** can be leveraged as below.

::

  $ cat /opt/ycsb.sh
  #!/bin/bash

  (/usr/bin/screen -d -m /home/elk/ycsb-0.15.0/bin/ycsb run mongodb -s -P /home/elk/ycsb-0.15.0/workloads/workloada) &
  $ cat /etc/systemd/system/ycsb.service
  [Unit]
  Description=Start MongoDB Benchmarking
  After=mongodb.service

  [Service]
  Type=forking
  ExecStart=/opt/ycsb.sh

  [Install]
  WantedBy=multi-user.target

**Notes**: **fork** needs to be implemented by the app or the script to be executed.

Here Document
----------------

Here document in shell is used to feed a command list(multiple line of strings) to an interactive program or a command, such as ftp, cat, ex.

It has 2 x forms:

- Respect leading tabs(but not spaces): <<EOF
- Suppress leading tabs: <<-EOF

Use a variable containing multiple lines of string
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  lines=`ls -l /etc`
  echo $lines # if lines contains special words, signs, this may not work
  echo "$lines" # this always works

Redirect here document output
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  {
     mongo 192.168.1.101/ycsb <<EOF
     use ycsb;
     sh.status(true);
     EOF
  }  | tee -a /tmp/output

Avoid variable interpretation
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- Use quote:

  ::

    cat > /tmp/a.sh <<"EOF"
    var1=$( ls -l )
    for i in $(seq 1 10); do
      echo $i
    done
    EOF

- Use escape: variables w/o eascaping will still be interpreted

  ::

    cat > /tmp/a.sh <<EOF
    var1=\$( ls -l )
    for i in \$(seq 1 10); do
      echo \$i
    done
    EOF

read
------

Here String
~~~~~~~~~~~~~

**<<<** is here string, a form of here document. It is used as: COMMAND <<< $WORD, where $WORD is expanded and fed to the stdin of COMMAND.

Sample:

::

  while read -r line; do
  command1
  command2
  ......
  done <<< "$variable_name"

Respect leadning and trailing whitespace
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  IFS= read -r abc
  # if abc is "   hello   "
  # IFS= will make read respect them, so abc will be "   hello   "
  # without IFS=, abc will be "hello"
  echo $abc

Define a variable containing multiple lines of string
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Note**: a variable should be enclosed in double quotes while referring to it, otherwise, it will be treated as a single line string due to the shell expansion.

::

  read -d '' var_name <<-EOF
  line1
  ...
  EOF
  echo "$var_name"

Read from multiple files within one loop
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  USRF="users.txt"
  ATTRF="attributes.txt"

  while read USR; do
    read -r GENDER <&3
    read -r AGE <&3
    echo "$USR:$GENDER:$AGE"
  done <$USRF 3<$ATTRF

awk
------

Built-in Variables
~~~~~~~~~~~~~~~~~~~~~

- FS : input field separator
- OFS: output field separator
- RS : record separator
- ORS: output record separator
- NF : number of fields
- NR : number of records

Common Command Format
~~~~~~~~~~~~~~~~~~~~~~~~

::

  awk '
     BEGIN { actions }
     /pattern/ { actions }
     /pattern/ { actions }
     .....
     END { actions }
  ' filenames

awk define variables
~~~~~~~~~~~~~~~~~~~~~~~

-v <variable name>=<variable value>

Examples:

::

  awk -v name=Jerry 'BEGIN{printf "Name = %s\n", name}'
  awk -F= -v key=$1 '{if($1==key) print $2}'
  Notes:
    1. The first $1 is the first shell positional parameter;
    2. The second $1, and the following $2 is the first and second column/field of a input record.

Get lines whose fields/columns is a special word
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  awk '$7=="some_word" {for(i=1;i<=NF;++i){printf "%s ", $i}; printf "\n"}'

Get lines whose fields/columns match a sepcial word
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  awk '$7~/some_word/ {for(i=1;i<=NF;++i){printf "%s ", $i}; printf "\n"}'

Output a range of fields
~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  awk '{for(i=3;i<=8;++i){printf "%s ", $i}; printf "\n"}'

Calculate the sum of a column
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  awk '{sum += $3}END{print sum}'

Calculate duplicate rows with hash
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  # column 1 is used as the key, and calculate the sum when it is the same
  awk '{cnt[$1] += $2}END{for (k in cnt) print k, cnt[k]}'

Get the last 2 columns
~~~~~~~~~~~~~~~~~~~~~~~~~

::

  ping -c 100 localhost | awk '/time=/{print $(NF-1), $NF}'

Find
------

Find and sort by time
~~~~~~~~~~~~~~~~~~~~~~~

::

  find . -type f -printf '%T@ %p\n' | sort -k 1 -n [-r]

Find files newer than
~~~~~~~~~~~~~~~~~~~~~~~

::

  find . -type f -newermt '2021-02-05'
  find -newermt "$(date '+%Y-%m-%d %H:%M:%S' -d '10 minutes ago')"

Find files and show their contents together with file names
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  find /sys/kernel/mm/hugepages/hugepages-2048kB/ -type f -print0 | xargs -0 -r grep .
  find . -type f -name "*.sh" -print0 | xargs -0 -n1 grep -H 'hello world'

Exclude paths
~~~~~~~~~~~~~~~

::

  # NOTES:
  # -path for glob
  # -regex for regular expression
  # ./ prefix is a must
  # /* suffix is a must
  find . -type f ! -path ./samples/* ! -path ./Documentation/*
  find /proc/ ! -regex '/proc/[0-9]+/*'

Delete broken links
~~~~~~~~~~~~~~~~~~~~

::

  find /etc/apache2 -type l ! -exec test -e {} \; -print | sudo xargs rm

Find files which are executable
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  find /path/to/directory -type f -perm /u+x,g+x,o+x
  find /path/to/directory -type f -executable

ssh
-------

ssh client configuration
~~~~~~~~~~~~~~~~~~~~~~~~~~~

1. Configuration file: ~/.ssh/config(mode 400, and create if it does not exist);
2. man ssh_config to find all supported options;
3. Format:

   ::

     Host <host pattern, such as *, ip, fqdn>
         <Option Name> <Option Value>
         ......
     --- OR ---
     Host <host pattern, such as *, ip, fqdn>
         <Option Name>=<Option Value>
         ......

4. Examples:

   - Disable host key checking:

     ::

       Host *
           StrictHostKeyChecking no
           UserKnownHostsFile /dev/null

   - Use ssh v1 only

     ::

       Host *
           Protocol 1

Add ssh public key to remote servers
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To configure key based ssh login, the ssl public key (generated with ssh-keygen -t rsa) needs to be copied and appended to the file **~/.ssh/authorized_keys** on remote servers.

Command **ssh-copy-id** can be leveraged to do the work automatically.

Enable Additional SSH Key Algorithms
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

When ssh to some equipment, errors as below may be prompted:

::

  no matching key exchange method found. Their offer: xxx, yyy

To login such equipement:

::

  ssh -oKexAlgorithms=+xxx <user>@<equipment>

Run multiple Remote Commands with SSH
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  # ssh <user>@<host> ""
  ssh root@192.168.10.10 "while : ; do top -b -o '+%MEM' | head -n 10; echo; sleep 3; done"
  ssh root@192.168.10.10 "while : ; do top -b -o '+%MEM' | head -n 10; echo; sleep 3; done"
  ssh root@192.168.10.10 "vmstat -w -S m 5 10"
  ssh root@192.168.10.10 "while :; do docker stats --no-stream; echo; sleep 5; done"

ssh login with a private key
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  # make sure the permission of a private key is configured as 400 or 600
  ssh -i /path/to/private/key/pem root@xxx.xxx.xxx.xxx

Run commands without password by using sshpass
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  # if multiple commands are used, they can be formated as "command1 && echo && command2 && ..." or "command1; command2; ..."
  sshpass -p <password> ssh -p <port> -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=5 -o LogLevel=error <IP> '<commands>'

Verify ssh password with a loop with sshpass
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  #!/bin/bash
  p="password.txt"
  f="ips.txt"
  while read -r IPADDR; do
    # sshpass needs to be processed specially, refer to https://superuser.com/questions/1236851/what-is-wrong-with-this-while-loop
    </dev/null sshpass -f $p  ssh -v -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=error ${IPADDR} ls>/dev/null 2>/dev/null
    if [[ $? -eq 0 ]]; then
      echo "$IPADDR SUCCESS"
    else
      echo "$IPADDR FAIL"
    fi
  done < "$f"

Loop
------

Single line for loop with background jobs
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  # & is enough, if &; is used, an error will be triggered
  # refer to https://unix.stackexchange.com/questions/91684/use-ampersand-in-single-line-bash-loop
  for((i=1;i<=255;i+=1)); do echo $i; /opt/app1 & done

for loop a range
~~~~~~~~~~~~~~~~~~~

::

  for i in {1..10}; do
    echo $i
  done
  for i in `seq 1 10`; do
    echo $i
  done
  round=10
  for i in `seq 1 $round 2`; do
    echo $i
  done

Operations on CPU/Process
----------------------------

Show CPU Summary
~~~~~~~~~~~~~~~~~~

Show CPU architecture, features, sockers, cores, etc.

::

  lscpu

Show cpu and cache topology
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  # Install hwloc and hwloc-gui at first
  lstopo-no-graphics --no-io --no-legend --of txt

Show CPU frequency and idle statistics
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Refer to https://metebalci.com/blog/a-minimum-complete-tutorial-of-cpu-power-management-c-states-and-p-states/ for C-states

::

  # note: if a vm with mwait enabled is monitored:
  # - top: all vcpus will be shown with almost 100% cpu usage
  # - turbostat: the real cpu usage is shown since turbostat
  turbostat # https://www.linux.org/docs/man8/turbostat.html
  cpupower monitor # https://www.linux.org/docs/man1/cpupower.html
  powertop

Make a process run on spcified cpu cores
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  # query current affinity
  taskset -acp <pid>
  # change the affinity
  taskset -cp <cpu cores, such as 1,2,3> <pid>

  # run a program directly on specified cpu cores
  # taskset -c 0,36 stress-ng --cpu 2 -l 100
  taskset -c 0 stress-ng --cpu 1 -l 100 &
  taskset -c 36 stress-ng --cpu 1 -l 100 &
  mpstat -P 0,36 1 # monitor the effects

Change limit settings for running process
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  prlimit --nofile=40960:40960 -p 107613


Show cpu, memory, etc. usage per process
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

ps command can be used with customized output format to show per process inforamtion including cpu, mem, cgroups, etc.

::

  ps -e -o "pid,%cpu,%mem,state,tname,time,command"

List Non-Kernel Process
~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  ps --ppid 2 -p 2 --deselect

List Task/Process Switch Stats
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  pidstat -w

Shiw workding dir of a process
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  pwdx <pid>

Sort based on fields with top
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::


  # Refer to section "FIELDS / Columns" of "man top" for supported fields
  # non-interactive
  top -b -o '+%MEM'
  # interactive: press f->up/down to select a filed->press s->press q
  top # then press keys accordingly

Only show activities of specified cpu cores
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  # 1. top interactive
  top
  # then follow below steps:
  # press f -> select filed "P" -> press <Space> to toggle display
  # select "P" -> press <Right> -> press <Up> to move "P" to the top
  # press q to go back to the display
  # press "o" to filter -> enter P=0 to filter only process on process 0/10/...
  # press "=" to clear filters
  # notes: only one condition is supported

  # 2. top non-interactive
  top
  # then follow below steps:
  # press f -> select filed "P" -> press <Space> to toggle display
  # select "P" -> press <Right> -> press <Up> to move "P" to the top
  # press q to go back to the display
  # press W to write persistent top config .toprc
  top -bc | awk '$1==0 || $1==36'
  # note: remember to delete .toprc after usage

Only show specified processes with top
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  top -c -p <process id, ...>

Show process threads
~~~~~~~~~~~~~~~~~~~~~~~~

::

  ps -T -p <pid>
  top -H -p <pid>

Show the CPU process/thread is running on
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  # psr is the physical cpu
  ps -F -p <pid>
  ps -T -F -p <pid>
  ps -T -p 41869 -o pid,spid,psr,comm
  taskset -acp <pid>

Show process kernel stack
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Notes: gstack, eu-stack works the same.

::

  cat /proc/<PID>/stack # main thread stack
  cat /proc/<PID>/task/<TID>/stack # stack for child process
  pstack <PID> # print kernel stack for the main and children within the same group

Show process shcedule class
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  ps -cTef

Change process scheduler policy
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  chrt -r -p <process id>

Show cpu power suppy/consumption
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  ipmi-sensors | grep Total_Power
  ipmitool sdr | grep Total_Power
  # lm_sensors are recommended against ipmitools
  yum install -y lm_sensors
  sensors

Operations on memory
---------------------

Check slab information
~~~~~~~~~~~~~~~~~~~~~~~~

::

  slabtop
  cat /proc/slabinfo
  vmstat -m

Check page allocator statistics
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  # page allocator is actully the buddy system
  cat /proc/buddyinfo
  cat /proc/pagetypeinfo

Check memory watermark
~~~~~~~~~~~~~~~~~~~~~~~~~

::

  cat /proc/zoneinfo

Cache line info
~~~~~~~~~~~~~~~~~

::

  getconf -a | grep CACHE_LINESIZE

Check overcommit config
~~~~~~~~~~~~~~~~~~~~~~~~

::

  cat /proc/sys/vm/overcommit_memory
  cat /proc/sys/vm/overcommit_ratio

Check/Adjust oom score
~~~~~~~~~~~~~~~~~~~~~~~

::

  cat /proc/<pid>/oom_score
  cat /proc/<pid>/oom_score_adj
  echo -1000 > /proc/<pid>/oom_score_adj

Check vmalloc address info
~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  cat /proc/vmallocinfo

Check memory space address info
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  cat /proc/iomem

Random number
---------------

Get a simple random int within a range
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  # use shuf
  N=$(shuf -i 1-100 -n 1)
  echo $N
  # use RANDOM
  echo $RANDOM

Get pseudo random numbers in binary, decimal, hex, etc.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  # od supports output format as character, decimal, unsigned decimal, hex, etc.
  # xxd, hexdump also supports similar functions with their specific focus, man xxd|hexdump
  od -vAn -N2 -tu2 < /dev/urandom

Randomness test
~~~~~~~~~~~~~~~~

::

  # FIPS 140-2 tests
  rngtest -c 1000000 </dev/urandom
  # Diehard - https://webhome.phy.duke.edu/~rgb/General/dieharder.php
  # diehard -g -l
  cat /dev/urandom | diehard -g 200 -a

systemd
----------

Show service definition
~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  systemctl cat xxx
  systemctl show xxx

List services/sessions/slices
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  # man systemd: to find all supported types
  systemctl list-units --type=service
  systemctl list-units --type=scope
  systemctl list-units --type=slice
  systemd-loginctl list-sessions
  ls /run/systemd/sessions

Control and check session
~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  ls /run/systemd/system
  cat /run/systemd/system/session-3598362.scope
  systemd-loginctl list-sessions
  systemd-loginctl show-session xxx
  systemd-loginctl terminate-session xxx

journalctl
------------

Check service logs based on time window
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  systemctl | grep '<service name>' ---> locate the service unit name
  journalctl -S <time stamp> -u <service name>

Check latest logs
~~~~~~~~~~~~~~~~~~~

::

  journalctl -f ---> As tail

Do not wrap log lines
~~~~~~~~~~~~~~~~~~~~~~~

::

  journalctl --all --output cat -u <service name>

Clean logs
~~~~~~~~~~~~

::

  journalctl --flush --rotate
  journalctl --vacuum-time=1s

Show logs related with a specific process
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  journalctl _PID=`pidof pal`

Show logs for specified boot
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  journalctl --list-boots
  journalctl -b <index, such as 0, -1, etc.> -e

Show logs for syslog identifiers
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  journalctl -t vhost-user -t systemd -b0

zsh tips
-----------

Common
~~~~~~~~~

- zsh reference card: http://www.bash2zsh.com/zsh_refcard/refcard.pdf
- zsh tips: http://grml.org/zsh/zsh-lovers.html

zsh set/unset options
~~~~~~~~~~~~~~~~~~~~~~~~

::

  setopt # Display all enabled options
  setopt HIST_IGNORE_ALL_DUPS
  unsetopt # Display all off options
  unsetopt HIST_IGNORE_ALL_DUPS

Run jobs in background
--------------------------

Wait jobs
~~~~~~~~~~~~

::

  While : ; do
      pids=""
      <process 1/command 1>  &
      pids="$pids $!"
      ……  &
      <process N/command N> &
      pids="$pids $!"
      for id in $pids; do
          wait $id
          echo $?
      done
  done

Run a shell function with nohup
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  abc () {
    while : ; do
      echo "hello"
      sleep 1
    done
  }
  export -f abc
  nohup bash -c "abc" >/dev/null 2>&1 &

Change file attributes
--------------------------

::

  # use chattr to make a file append only, immutable(cannot be deleted), etc.
  lsattr abc
  chattr +i abc
  chattr -i abc

Who is on the server
----------------------

::

  # who is on the server
  who [...]
  # who is on the server and what they are doing
  w [...]

Hardware information qurey
----------------------------

Besides individual tools like lspci, lscpu, etc. which can be used to list special kinds of hardware devices, dmidecode can be used to query almost all kind of hardware:

::

  man dmidecode # check DMI TYPES section
  dmidecode -t 4 # CPU information
  dmidecode -t 17 # physical memory information
  ...

Error Detection And Correction query
--------------------------------------

::

  # memory related errors can be reported by EDAC module.
  # refer to https://www.kernel.org/doc/html/latest/driver-api/edac.html for basic concepts
  edac-util --report=ce
  edac-util --report=simple -vvv

Disable auto logout for CLI console
-------------------------------------

::

  # add to /etc/profile to persistent the setting
  export TMOUT=0

Command line calculation with bc
-----------------------------------

By default, bash does not support floating point calculation. For example, below expressions are not valid:

::

  # [[]] does not support floating point
  A=100.1
  B=100.1
  if [[ $A -eq $b ]]; then
    echo "Equal"
  fi

  # $(()) does not support floating point
  $((A + B))

To calculate floating point with bash, use bc as below:

::

  bc -l <<< "scale=10; $A == $B"
  bc <<< "scale=10; $A + $B"

Fork implementation with shell
---------------------------------

There are 2 x formats to achive forking with shell:

1. Through a function

   ::

     function abc() { xxx; xxx; ... }
     abc &

2. Through an anonymous function

   ::

     (xxx; xxx; ...) &

Disable IPv6
---------------

- sysctl

  - Add below contents in /etc/sysctl.conf

    ::

      net.ipv6.conf.all.disable_ipv6 = 1
      net.ipv6.conf.default.disable_ipv6 = 1
      net.ipv6.conf.lo.disable_ipv6 = 1

  - sysctl -p
  - cat /proc/sys/net/ipv6/conf/all/disable_ipv6 ===> If output is 1, IPv6 has been disabled. If not, try reboot the server.
  - Delete the IPv6 localhost definition entry from /etc/hosts
  - Regenerate the initial ram disk (initrd) on RHEL/CentOS: "dracut -f"

- Grub: add "ipv6.disable=1" to the linux line

  ::

     linux   /boot/vmlinuz-xxx xxx xxx ipv6.disable=1

Recode file to UTF-8
-----------------------

- recode -f UTF-8 <file name>

- Get driver name

  ::

    [root@LPAR2 ~]# lspci -k
    …...
    f7:01.0 Ethernet controller: Intel Corporation 82576 Gigabit Network Connection (rev 01)
            Subsystem: Intel Corporation Device 0000
            Kernel driver in use: igb
            Kernel modules: igb

sudoers: <user> ALL = (<user to act as>) <commands>
------------------------------------------------------

::

  Examples:
    # User "alan" can run commands "/bin/ls" and "/bin/kill" as user "root", "bin" or group "operator", "system"
    alan   ALL = (root, bin : operator, system) /bin/ls, /bin/kill
    # User "superadm" can run all commands as anyone
    superadm  ALL=(ALL)   ALL
    # User "adm" can sudo run all "root"'s commands without password'
    adm ALL = (root) NOPASSWD:ALL
    # Users in group "wheel" can run all commands as anyone
    %wheel ALL=(ALL) ALL

Grub2 change boot order
--------------------------

**NOTE**: grubby is recommended if it is available.

::

  awk -F\' '$1=="menuentry " {print i++ " : " $2}' /etc/grub2.cfg
  grub2-editenv list
  grub2-set-default 2
  grub2-editenv list

Disable console log
----------------------

::

  # dmesg -n 1

lsof tips
------------

- lsof <file> ---> Which processes are using the file
- lsof +D <directory> ---> Which processed are accessing the directory, and which files under the directory are being accessed
- lsof -nP -i :80 ---> which process is listening on a specific port

tail tips
----------

By default, tail -f follows a file based on the file descriptor. Once the file is rotated, the file descript gets changed, tail -f will stop working.

::

  tail -f /path/to/file # if file descriptor never changes
  tail --follow=name --retry /path/to/file # if file may get rotated which lead to fd changes

head and tail together
-----------------------

::

  cat /etc/passwd | (head; echo; tail)

Process the new line character
--------------------------------

- Delete trailing new line

  ::

    tr -d '\n'

- Change trailing new line to some other character

  ::

    tr '\n' ','

Use shell variable in sed
----------------------------

::

  sed -i -e "s/bindIp:.*$/bindIp: $IP_ADDR/" /etc/mongod.conf

Make grep match for only 1 time
----------------------------------

::

  grep -m1 …...

grep with multiple patterns
-----------------------------

::

  grep -E 'a|b|c|d|e'
  grep -e 'a' -e 'b' -e 'c' -e 'd' -e 'e'
  grep -v -e 'a' -e 'b' -e 'c' -e 'd' -e 'e'

grep non greddy match
-----------------------

::

  # the default and extended(-E) grep does not support non greedy match,
  # perl mode(-P) should be used
  ps -ef | grep qemu-system-x86_64 | grep -Po 'bdf=.*?,'

Shell debugging
------------------

::

  #!/bin/bash -xvT
  # important: using single quote + insert "export PS4=xxx" into the script but not from CLI
  # set PS4 to print script filename, line num., func name
  export PS4='+(${BASH_SOURCE}:${LINENO}):${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
  # or with only script filename and lineno
  # export PS4='${BASH_SOURCE}:${LINENO}: '
  # --- OR ---
  #!/bin/bash
  set -o errexit
  set -o xtrace
  set -o functrace
  export PS4='+(${BASH_SOURCE}:${LINENO}):${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

Posix regular expression definitions
--------------------------------------

::

  man 7 regex

Print section between two regular expressions with sed
---------------------------------------------------------

::

  sed -n -e '/reg1/,/reg2/p' <file>

Remove unprintable characters from a file with sed
----------------------------------------------------

::

  sed -e 's/[^[:print:]]//g' /path/to/file

Change soft link with sed
----------------------------

::

  sed -i --follow-symlinks ...

Sort based on several fields
-------------------------------

::

  sort -k <field 1 order> -k <field 2 ordr> ... [-n] [-r]

Sort with a random order
----------------------------

::

  cat /etc/passwd | shuf

Preserve colors with less
----------------------------

::

  rg task_struct | less -R

String Contains in Bash
--------------------------

- Leverage Wildcard

  ::

    if [[ "$string" == *"$substring"*  ]]; then
      echo "'$string' contains '$substring'"
    else
      echo "'$string' does not contain '$substring'"
    done

- Leverage Regular Expression

  ::

    if [[ "$string" =~ $substring  ]]; then
      echo "'$string' contains '$substring'"
    else
      echo "'$string' does not contain '$substring'"
    fi

Tarball with xz
------------------

xz is a newer compression tool than gz, bz, bz2, etc. It delivers better compression ratio and performance.

::

  tar -cJf <archive.tar.xz> <files>


Record and replay linux CMD screen
-------------------------------------

::

  script --timing=file.tm script.out

  cmd1
  cmd2
  ...
  exit

  scriptreplay --timing file.tm --typescript script.out

Check nfs IO stat
--------------------

::

  nfsstat -l

Assign hostname dynamically with DHCP
----------------------------------------

1. **option host-name** can be used to assign a hostname while assigning IP - https://www.isc.org/wp-content/uploads/2017/08/dhcp41options.html;
2. **dhcp-eval** can be leveraged to generate a hostname dynamically - https://www.isc.org/wp-content/uploads/2017/08/dhcp41eval.html.

Change System Clock
----------------------

timedatectl is a new utility, which comes as a part of systemd system and service manager, a replacement for old traditional date command used in sysvinit daemon.

::

  timedatectl list-timezones
  timedatectl set-timezone Asia/Shanghai

Change System Locale
-----------------------

::

  # some locales such as zh_CN.utf8 need additional langpacks
  # yum search langpack
  # yum search languagepack
  locale -a
  export LC_ALL=en_US.utf8

Use openssl to download a certificate
-----------------------------------------

::

  openssl s_client -showcerts -connect <IP or FQDN>:<Port> </dev/null 2>/dev/null | openssl x509 -outform PEM > ca.pem

Setup CA with OpenSSL
-------------------------

This tip only lists the most important commands for easy reference. For more information, refer to the `original doc <https://gist.github.com/soarez/9688998>`_.

**Applicant Part:**

- Generate an RSA private key for CA:

  ::

    openssl genrsa -out example.org.key 2048

- Inspect the key:

  ::

    openssl rsa -in example.org.key -noout -text

- Extract RSA public key from the private key:

  ::

    openssl rsa -in example.org.key -pubout -out example.org.pubkey
    openssl rsa -in example.org.pubkey -pubin -noout -text

- Generate a CSR (Certificate Signing Request):

  ::

    openssl req -new -key example.org.key -out example.org.csr
    openssl req -in example.org.csr -noout -text

**CA Part:**

- Generate a private key for the root CA:

  ::

    openssl genrsa -out ca.key 2048

- Generate a self signed certificate for the CA:

  ::

    openssl req -new -x509 -key ca.key -out ca.crt

- Sign the applicant CSR to generate a certificate:

  ::

    openssl x509 -req -in example.org.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out example.org.crt
    openssl x509 -in example.org.crt -noout -text

- Verify the serial number assigned:

  ::

    cat ca.srl
    openssl x509 -in example.org.crt -noout -text | grep 'Serial Number' -A1

- Verify the certificate:

  ::

    openssl verify -CAfile ca.crt example.org.crt

ipmitool
------------

- Get system status

  ::

    # IPMI interface will either lan or lanplus
    ipmitool -I lanplus -H 192.168.10.10 -U admin -P password chassis status

- Power Ops

  ::

    ipmitool -I lanplus -H 192.168.10.10 -U admin -P password power <on|off|soft|reset>

- Change boot order

  ::

    ipmitool -I lanplus -H 192.168.10.10 -U admin -P password chassis bootdev <bios|pxe|cdrom|...>

- Reset IPMI controller

  ::

    ipmitool -I lanplus -H 192.168.10.10 -U admin -P password mc reset [warm|cold]

- Create a console connection

  ::

    # deactive at fist
    ipmitool -I lanplus -H 192.168.10.10 -U admin -P password sol deactivate
    ipmitool -I lanplus -H 192.168.10.10 -U admin -P password sol activate
    # type ~. to quite the sol session

- Check sensors

  ::

    ipmitool sdr | grep Total_Power
    ipmitool-sensors

Check initramfs contents
----------------------------

::

  lsinitrd <initrd image>

Caculate the size of hugepage used by a specified process
--------------------------------------------------------------

::

  # say the huge page size is 2M
  grep -B 11 'KernelPageSize:     2048 kB' /proc/[PID]/smaps | grep "^Size:" | awk 'BEGIN{sum=0}{sum+=$2}END{print sum/1024}'

Caculate used huge pages of a system
--------------------------------------

::

  # say the huge page size is 2M
  nr=`cat /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages`
  free=`cat /sys/kernel/mm/hugepages/hugepages-2048kB/free_hugepages`
  used=$((nr - free))
  echo $((used*2))M;
  echo $((used*2/1024))G

Create an array based on command output
------------------------------------------

::

  a1=( $(ps -T -o pid,tid,psr,comm -p `pgrep -f 92e50bee-568d-4cc9-ad5a-617a6eb8206e` | grep CPU | awk '{print $2}' ) )
  echo ${a[*]}

Linux symbol table
-------------------

::

  # find the introduction
  man procfs
  cat /proc/kallsyms
  # for symbol type
  man nm

Disable Windows PATH with WSL
-------------------------------

::

  # create /etc/wsl.conf with below contents within a wsl distribution
  [interop]
  appendWindowsPath = false
  # restart the wsl distribution
  wsl --shutdown
  wsl -d Ubuntu

autoexpect
-----------

- expect scripts can be leveraged for autoamtion interactive CLI based tasks. But it is tedious to write such a script.
- autoexpect can be used to generating the initial expect script more quickly.

Split large files
-------------------

::

  split -d -b 100M file_name file_name.
  cat `ls file_name.*` > file_name

Join multiple lines into one
-----------------------------

::

  # paste -sd
  cat /etc/passwd | sed 's/:.*$//' | paste -sd '|'

Bind to both ipv4 and ipv6 with all addresses
-----------------------------------------------

::

  bind 0.0.0.0 # bind to all ipv4
  bind ::0 # bint to all ipv6
  bind 0.0.0.0 ::0 # bind to both ipv4 and ipv6
  bind 0.0.0.0:80 ::0:80 # bint to the 80 port
  bind 0.0.0.0:80 :::80 # bint to the 80 port

Create application core dump
-----------------------------

::

  # it is recommended to change ulimit in its configuration file
  ulimit -c unlimited
  kill -11 <pid> # different application may accept different signals to trigger a core dump
  coredumpctl list
  coredumpctl list <core dump pid>

max number of open file descriptors
-------------------------------------

- it is well known that tuning nofile options within /etc/security/limits.conf can control the max num. of open fds;
- all documents including the manpage for limits.conf declare **-1** for nofile mean no limited;
- however, on some system, -1 may lead to login permission deny;
- hence, nofile should be set to a value less than or equal to **sysctl fs.nr_open**

Display /proc/interrupts w/o wrapping
---------------------------------------

::

  less -S /proc/interrupts

Manpages db update
---------------------

if apropos, man -k give no results:

::

  # run either of below based on your distribution
  makewhatis
  mandb

Change password non-interactive
---------------------------------

::

  echo 'root:password' | chpasswd

Write message to serial log(dmesg)
------------------------------------

::

  echo "hello world" >>/dev/kmsg

Show timestamp within history output
---------------------------------------

::

  help history
  export HISTTIMEFORMAT="%F %T "
  history

========
Disks
========

List all SCSI devices
------------------------

**sg_map** can be used to list all devices support SCSI, such as sd, sr, st, etc. In the meanwhile, it can also list the well known host:bus:scsi:lun inforamtion as lsscsi.

Note: sg stands for generic SCSI driver, it is generalized (but lower level) than its siblings(sd, sr, etc.) and tends to be used on SCSI devices that don't fit into the already serviced categories. When the type for a SCSI device cannot be recognized, it will be shown as a sg device.

::

  # sg_map -x
  /dev/sg0  1 0 0 0  5  /dev/sr0
  /dev/sg1  2 0 0 0  0  /dev/sda

**lsblk** can also help list quite some information about block devices:

::

  # List SCSI devices
  lsblk -S
  # Show topology information
  lsblk -Tt
  # Show devices and associated file system information
  lsblk -f
  # Show device paths
  lsblk -p

Create a LV with all free space
----------------------------------

::

  lvcreate -l 100%FREE -n <LV name> <VG name>

Find the corresponding dm-X device for a lv
---------------------------------------------

::

  dmsetup ls # find the major, minor number for lv device
  ls -l /dev/dm-* # based on the major, minor number for the dm-X device

Query disk basic info like model, sn, firmware, etc.
-------------------------------------------------------

::

  smartctl -i /dev/sda

gdisk
-------

- Designed for GUID partition table;
- Able to backup and load partition data(sgdisk -b/-l)

sg_inq/sg3_inq
-----------------

::

  # sg_inq -p 0 /dev/<device name>
   Only hex output supported. sg_vpd decodes more pages.
  VPD INQUIRY, page code=0x00:
     [PQual=0  Peripheral device type: disk]
     Supported VPD pages:
       0x0        Supported VPD pages
       0x80       Unit serial number
       0x83       Device identification
       0x8f       Third party copy
       0xb0       Block limits (sbc2)
       0xb1       Block device characteristics (sbc3)
       0xb2       Logical block provisioning (sbc3)
  # sg_inq -p 0x83 /dev/<device name>

Rescan/discover LUN/disk without reboot
------------------------------------------

- FC

  ::

    # find . -name "scan"
    # echo '- - -' > ./devices/pci0000:00/0000:00:07.1/ata1/host0/scsi_host/host0/scan
    ---OR---
    # echo '- - -' > /sys/class/scsi_host/host0/scan
    …
    # lsblk

- iSCSI

  ::

      iscsiadm -m session
      iscsiadm -m session --sid=<session ID> --rescan
      # or rescan all sessions
      iscsiadm -m session --rescan

Remove a SCSI/SAN disk when it is dead
-----------------------------------------

::

  ~$ sudo lsscsi
  [0:2:0:0]    disk    Lenovo   720i             4.23  /dev/sda
  [0:2:1:0]    disk    Lenovo   720i             4.23  /dev/sdb
  [0:2:2:0]    disk    Lenovo   720i             4.23  /dev/sdc
  [0:2:3:0]    disk    Lenovo   720i             4.23  /dev/sdd
  [1:0:0:0]    disk    Single   Flash Reader     1.00  /dev/sde
  [4:0:0:0]    cd/dvd  PLDS     DVD-RW DU8A5SH   BL61  /dev/sr0
  [14:0:1:0]   disk    DGC      LUNZ             4100  /dev/sdf

  ~$ echo 1 | sudo tee /sys/bus/scsi/devices/${H:B:T:L}/delete
  (Note: H:B:T:L is the bus address output of lsscsi for sdf)

  ~$ sudo lsscsi
  [0:2:0:0]    disk    Lenovo   720i             4.23  /dev/sda
  [0:2:1:0]    disk    Lenovo   720i             4.23  /dev/sdb
  [0:2:2:0]    disk    Lenovo   720i             4.23  /dev/sdc
  [0:2:3:0]    disk    Lenovo   720i             4.23  /dev/sdd
  [1:0:0:0]    disk    Single   Flash Reader     1.00  /dev/sde
  [4:0:0:0]    cd/dvd  PLDS     DVD-RW DU8A5SH   BL61  /dev/sr0

Change I/O Scheduler
-----------------------

::

  # persistent - may not work for some systems
  grubby --update-kernel=ALL --args="elevator=bfq"
  # on the fly
  cat /sys/block/sda/queue/scheduler
  echo bfq > /sys/block/sda/queue/scheduler
  cat /sys/block/sda/queue/scheduler

View/Create/Remove SCSI Persistent Reservation Keys
------------------------------------------------------

Refer to https://access.redhat.com/solutions/43402

Tool needed - sg3_utils
~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  yum install sg3_utils

View registered keys
~~~~~~~~~~~~~~~~~~~~~~~

::

  sg_persist --in -k -d /dev/<DEVICE>

View the reservations
~~~~~~~~~~~~~~~~~~~~~~~~

::

  sg_persist --in -r -d /dev/<DEVICE>

View more info about keys
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  sg_persist --in -s -d /dev/<DEVICE>

Register a key
~~~~~~~~~~~~~~~~~

::

  sg_persist --out --register --param-sark=<KEY> /dev/<DEVICE>

Take out a reservation
~~~~~~~~~~~~~~~~~~~~~~~~~

::

  sg_persist --out --reserve --param-rk=<KEY> --prout-type=<TYPE> /dev/<DEVICE>

Release a reservation
~~~~~~~~~~~~~~~~~~~~~~~~

::

  sg_persist --out --release --param-rk=<KEY> --prout-type=<TYPE> /dev/<DEVICE>

Unregister a key
~~~~~~~~~~~~~~~~~~~

::

  sg_persist --out --register --param-rk=<KEY> /dev/<DEVICE>

Clear the reservation and all registered keys
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  sg_persist --out --clear --param-rk=<KEY> /dev/<DEVICE>

A simple script to clear all reservations
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  #!/usr/bin/bash

  DEVICE=$1

  KEYS=`sg_persist --in -k -d $DEVICE | grep '^ \+0x' | awk '{print $1}' | uniq`

  for k in $KEYS; do
    sg_persist --out --clear --param-rk=${k} ${DEVICE}
  done

NVME
------

Refer to below docs:

- https://narasimhan-v.github.io/2020/06/12/Managing-NVMe-Namespaces.html
- https://www.drewthorst.com/posts/nvme/namespaces/readme/

Delete a NVME name space
~~~~~~~~~~~~~~~~~~~~~~~~~~

::

	[root@devbox ~]# nvme list
	Node             SN                   Model                                    Namespace Usage                      Format           FW Rev
	---------------- -------------------- ---------------------------------------- --------- -------------------------- ---------------- --------
	/dev/nvme0n1     S5G3NA0R107888       SAMSUNG MZWLJ3T8HBLS-0007C               1           3.84  TB /   3.84  TB      4 KiB +  0 B   EPK9BJ5Q
	/dev/nvme1n1     S5G3NA0R107886       SAMSUNG MZWLJ3T8HBLS-0007C               1           3.84  TB /   3.84  TB      4 KiB +  0 B   EPK9BJ5Q
	/dev/nvme2n1     S5G3NA0R107879       SAMSUNG MZWLJ3T8HBLS-0007C               1           3.84  TB /   3.84  TB      4 KiB +  0 B   EPK9BJ5Q
	/dev/nvme3n1     S5G3NA0R107885       SAMSUNG MZWLJ3T8HBLS-0007C               1           3.84  TB /   3.84  TB      4 KiB +  0 B   EPK9BJ5Q
	[root@devbox ~]# nvme id-ctrl /dev/nvme0 | grep cntlid
	cntlid    : 41
	[root@devbox ~]# nvme detach-ns /dev/nvme0 -n 1 -c 0x41
	detach-ns: Success, nsid:1
	[root@devbox ~]# nvme ns-rescan /dev/nvme0
	[root@devbox ~]# nvme list
	Node             SN                   Model                                    Namespace Usage                      Format           FW Rev
	---------------- -------------------- ---------------------------------------- --------- -------------------------- ---------------- --------
	/dev/nvme1n1     S5G3NA0R107886       SAMSUNG MZWLJ3T8HBLS-0007C               1           3.84  TB /   3.84  TB      4 KiB +  0 B   EPK9BJ5Q
	/dev/nvme2n1     S5G3NA0R107879       SAMSUNG MZWLJ3T8HBLS-0007C               1           3.84  TB /   3.84  TB      4 KiB +  0 B   EPK9BJ5Q
	/dev/nvme3n1     S5G3NA0R107885       SAMSUNG MZWLJ3T8HBLS-0007C               1           3.84  TB /   3.84  TB      4 KiB +  0 B   EPK9BJ5Q

Create a NVMe name space
~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  # nvme multipath:
  # cat /sys/module/nvme_core/parameters/multipath
  # grubby --update-kernel=ALL --args="nvme_core.multipath=Y" # enable
  # grubby --update-kernel=ALL --args="nvme_core.multipath=N" # disable
  # when nvme multipath is on, /sys/bus/pci/devices/<pci addr>/nvme/nvmeX will have a dir named nvmeXc0n1
  # when nvme multipath is off, /sys/bus/pci/devices/<pci addr>/nvme/nvmeX will have a dir named nvmeXn1
  [root@devbox ~]# nvme list-subsys
  nvme-subsys0 - NQN=nqn.1994-11.com.samsung:nvme:PM1733:2.5-inch:S5G3NA0R107888
  \
   +- nvme0 pcie 0000:81:00.0 live
  nvme-subsys1 - NQN=nqn.1994-11.com.samsung:nvme:PM1733:2.5-inch:S5G3NA0R107886
  \
   +- nvme1 pcie 0000:82:00.0 live
  nvme-subsys2 - NQN=nqn.1994-11.com.samsung:nvme:PM1733:2.5-inch:S5G3NA0R107879
  \
   +- nvme2 pcie 0000:83:00.0 live
  nvme-subsys3 - NQN=nqn.1994-11.com.samsung:nvme:PM1733:2.5-inch:S5G3NA0R107885
  \
   +- nvme3 pcie 0000:84:00.0 live
  [root@devbox ~]# ls -l /dev/nvme*
  crw------- 1 root root 243, 0 Dec 29 17:27 /dev/nvme0
  crw------- 1 root root 243, 1 Dec 29 17:27 /dev/nvme1
  brw-rw---- 1 root disk 259, 3 Dec 29 19:33 /dev/nvme1n1
  crw------- 1 root root 243, 2 Dec 29 17:27 /dev/nvme2
  brw-rw---- 1 root disk 259, 5 Dec 29 19:33 /dev/nvme2n1
  crw------- 1 root root 243, 3 Dec 29 17:27 /dev/nvme3
  brw-rw---- 1 root disk 259, 7 Dec 29 19:33 /dev/nvme3n1
  [root@devbox ~]# nvme id-ctrl /dev/nvme0 | grep cap
  tnvmcap   : 3840755982336
  unvmcap   : 0
  sanicap   : 0x3
  anacap    : 0
  [root@devbox ~]# echo 3840755982336 / 4096 | bc
  937684566
  [root@devbox ~]# nvme create-ns /dev/nvme0 -s 937684566 -c 937684566 -b 4096
  create-ns: Success, created nsid:1
  [root@devbox ~]# nvme list-ns /dev/nvme0 -a
  [   0]:0x1
  [root@devbox ~]# nvme id-ctrl /dev/nvme0 | grep cntlid
  cntlid    : 41
  [root@devbox ~]# nvme attach-ns /dev/nvme0 -n 0x1 -c 0x41
  attach-ns: Success, nsid:1
  [root@devbox ~]# nvme ns-rescan /dev/nvme0
  [root@devbox ~]# nvme list
  Node             SN                   Model                                    Namespace Usage                      Format           FW Rev
  ---------------- -------------------- ---------------------------------------- --------- -------------------------- ---------------- --------
  /dev/nvme0n1     S5G3NA0R107888       SAMSUNG MZWLJ3T8HBLS-0007C               1           3.84  TB /   3.84  TB      4 KiB +  0 B   EPK9BJ5Q
  /dev/nvme1n1     S5G3NA0R107886       SAMSUNG MZWLJ3T8HBLS-0007C               1           3.84  TB /   3.84  TB      4 KiB +  0 B   EPK9BJ5Q
  /dev/nvme2n1     S5G3NA0R107879       SAMSUNG MZWLJ3T8HBLS-0007C               1           3.84  TB /   3.84  TB      4 KiB +  0 B   EPK9BJ5Q
  /dev/nvme3n1     S5G3NA0R107885       SAMSUNG MZWLJ3T8HBLS-0007C               1           3.84  TB /   3.84  TB      4 KiB +  0 B   EPK9BJ5Q
  [root@devbox ~]# ls -l /dev/nvme*
  crw------- 1 root root 243, 0 Dec 29 17:27 /dev/nvme0
  brw-rw---- 1 root disk 259, 8 Dec 29 20:07 /dev/nvme0n1
  crw------- 1 root root 243, 1 Dec 29 17:27 /dev/nvme1
  brw-rw---- 1 root disk 259, 3 Dec 29 19:33 /dev/nvme1n1
  crw------- 1 root root 243, 2 Dec 29 17:27 /dev/nvme2
  brw-rw---- 1 root disk 259, 5 Dec 29 19:33 /dev/nvme2n1
  crw------- 1 root root 243, 3 Dec 29 17:27 /dev/nvme3
  brw-rw---- 1 root disk 259, 7 Dec 29 19:33 /dev/nvme3n1

====================
Package Mangement
====================

Which package provides the binary
------------------------------------

- RHEL/CentOS

  ::

    yum whatprovides nslookup

- Arch

  ::

    sudo pacman -Fy
    pacman -Fx <file name>

- Ubuntu

  ::

    sudo apt-get install apt-file
    sudo apt-file update
    apt-file search <file name>

Install a specified version RPM through yum
----------------------------------------------

::

  yum --showduplicates list <package name>
  yum install <package name>-<version>

Download src rpm
------------------

::

  yum install -y yum-utils
  yumdownloader --source kernel

Enable all repos w/o modifying configurations
-----------------------------------------------

::

  yum --enablerepo="*" search ...
  yum --enablerepo="*" install ...

arch aur package helper yay
------------------------------

Yet Another Yogurt - An AUR Helper Written in Go for archlinux based distros:

- Search a package : yay -Ss <package>
- Install a package: yay -S <package>
- Upgrade pacakges : yay -Syu --aur

Install a Package with a Specific Version on Ubuntu
------------------------------------------------------

::

  apt policy <package name>
  apt install <package name>=<version>

View package groups on Arch
------------------------------

::

  pacman -Sg[g]
  pacman -Qg[g]

List all available versions of a packge with yum
---------------------------------------------------

::

  [root@wnh9h1 yum.repos.d]# yum --showduplicates list kernel-uek.x86_64 | head
  Installed Packages
  kernel-uek.x86_64              3.8.13-35.3.1.el7uek                @anaconda/7.0
  Available Packages
  kernel-uek.x86_64              3.8.13-35.3.1.el7uek                ol7_UEKR3
  kernel-uek.x86_64              3.8.13-35.3.2.el7uek                ol7_UEKR3
  kernel-uek.x86_64              3.8.13-35.3.3.el7uek                ol7_UEKR3
  kernel-uek.x86_64              3.8.13-35.3.4.el7uek                ol7_UEKR3
  kernel-uek.x86_64              3.8.13-35.3.5.el7uek                ol7_UEKR3

EPEL for RHEL/CentOS/Fedora
-------------------------------

EPEL stands for **Extra Pacakges for Enterprise Linux**, a.k.a repositories for extra packages, which contains lots of tools such as fio, ipvsadm, etc.

::

  yum install epel-release

Fedora Copr
---------------

Fedora Copr is an easy-to-use automatic build system providing a package repository as its output. It can be used as package repositories for non official (including packages which are not covered by epel).

How to leverage Copr:

#. Go to https://copr.fedorainfracloud.org/;
#. Search the package which is not in the official repositories and epel, say "fasd";
#. Select/click the project which is the best from the result list;
#. Click the "Repo Download" link based on the target release;
#. Copy the URL field of the browser (not the content of the repo), say https://copr.fedorainfracloud.org/coprs/rdnetto/fasd/repo/fedora-33/rdnetto-fasd-fedora-33.repo for fasd;
#. sudo yum-config-manager --add-repo=<the repo link just copied>;
#. Check /etc/yum.repos.d/<the newly created repo name>.repo to make sure the contents generated is correct.

   For example, the baseurl for fasd is https://download.copr.fedorainfracloud.org/results/rdnetto/fasd/fedora-$releasever-$basearch/. If the OS used is CentOS 8, this will be interpreted as https://download.copr.fedorainfracloud.org/results/rdnetto/fasd/fedora-8-x86_64/ which is of course not correct. To fix this issue, hard code the url as https://download.copr.fedorainfracloud.org/results/rdnetto/fasd/fedora-33-$basearch/.

#. Done.

Install package offline on Arch
----------------------------------

1. Find the package by surfing: https://www.archlinux.org/packages/
2. **Download From Mirror** from the package page, the file <package name>.pkg.tar.xz will be downloaded;
3. sudo pacman -U <package name>.pkg.tar.xz

Create a local yum repo with DVD iso
---------------------------------------

- Disable all other repositories by make "enabled=0" on all files under /etc/yum.repos.d;
- Mount the iso: mount -o loop
- Create a repo config file under /etc/yum.repos.d with below contents, the name can be anything:

  ::

    [Repo Name]
    name=Description name
    baseurl=file://absolute path to the mount point
    enabled=1
    gpgcheck=0

- yum clean all
- yum repolist : You should be able to see the new repo
- Or through command line: yum-config-manager --add-repo file:///<Mount point> (Public key should be imported with command like "rpm --import /media/RPM-GPG-KEY-redhat-beta" before installing packages with the newly added repo )

Check yum repo package dependencies
-------------------------------------

::

  repoclosure --repo rawhide
  dnf repoclosure --repo rawhide

dnf
-------

dnf, which means dandified yum, is the default package manager for replacing yum.

Configuration
~~~~~~~~~~~~~~~~~~

- /etc/dnf/dnf.conf: dnf configuration
- /etc/yum.repos.d: repo definitions

List
~~~~~~~~

- dnf list --all: list all installed and available packages
- dnf list [<--installed\|--available\|--extras\|--obsoletes\|--recent>] [expression]: list packages [matching expression]
- dnf list --upgrades [expression]: list upgradable pacakges [matching expression]
- dnf list --autoremove: list orphaned packages

Info
~~~~~~~~~

- dnf info <package name>: show information for package
- dnf provides <path/to/file>: show packages own the file

Install
~~~~~~~~~~~

- dnf install <package name>: install package
- dnf install <path/to/local/rpm>: install a local rpm package
- dnf reinstall <package name>: reinstall package
- dnf downgrade <package name>: downgrade package

History
~~~~~~~~~~~~

- dnf history list: list dnf transactions
- dnf history info transaction: show info for a particular transaction
- dnf history redo transaction: redo a transaction
- dnf history rollback transaction: rollback a transaction
- dnf history undo transaction: undo a transaction

Update
~~~~~~~~~~

- dnf check-update: check if updates are available
- dnf upgrade: upgrade packages to latest version
- dnf upgrade-minimal: update major patches and security

Repo
~~~~~~~~

- dnf repolist [<--enabled\|--disabled\|--all>]: list repos
- dnf config­manager --add-repo=URL: add a repo

Note: config­manager is a dnf plugin which needs to be installed(dnf install dnf-plugins-core)

Group
~~~~~~~~~~

- dnf group summary group: show installed and available groups
- dnf group info <group name>: show information for a group
- dng group list [expression]: list groups [matching expression]

Uninstall
~~~~~~~~~~~~~~~

- dnf remove <package name>: remove a package
- dnf autoremove: remote orphaned packages

============
Services
============

Reload configuration file without restarting service
--------------------------------------------------------

SIGHUP as a notification about terminal closing event does not make sense for a daemon, because deamons are detached from their terminal. So the system will never send this signal to them. Then it is common practice for daemons to use it for another meaning, typically reloading the daemon's configuration.

::

  kill -s HUP <daemon pid>

Use Chrony for time sync
----------------------------

Modern Linux distributions start to use Chrony as the default application for time sync (NTP) instead of the classic ntpd. Chrony comes with 2 x programs:

- chronyd: the background daemon
- chronyc: CLI interface

Usage:

- Configuration (/etc/chrony.conf or /etc/chrony/chrony.conf) (Chrony NTP server and client use the same configuration)

  ::

    # Define the NTP server sources
    server 192.168.16.22 iburst

    # If it is configured as a NTP server, enable below options
    # Serve time even if not synchronized to a time source.
    #local stratum 0
    # Allow NTP client access from local network.
    #allow 192.168.0.0/16

- Start the service

  ::

    systemctl enable chronyd.service
    systemctl start chronyd.service

- Check NTP sources

  ::

    chronyc sources -v

- Check current time sync status

  ::

    chronyc tracking

- If time has been synced, it will be reflected from command "timedatectl"
- To sync time immediately

  ::

    chronyc makestep

kdump config
---------------

1. Install "kernel-debuginfo-common" and "kernel-debuginfo", by default, these two packages are not kept in yum repository, they need to be downloaded from internet;
#. Install "kexec-tools" and "crash":

   - yum install kexec-tools
   - yum install crash

#. Edit grub.cfg, append "crashkernel=yM@xMparameter " to kernel:

   - Y : memory reserved for dump-capture kernel;
   - X : the beginning of the reserved memory;
   - This can be done with command: grubby --update-kernel=ALL --args="crashkernel=yM@xM";
   - "crashkernel=yM@0" or "crashkernel=yM" should be used if kdump service cannot start;

#. It is also recommended to configure multiple options together: crashkernel=0M-2G:128M,2G-6G:256M,6G-8G:512M,8G-:768M
#. Reboot and check with command: cat /proc/iomem | grep 'Crash kernel';
#. Configure /etc/kdump.conf to set dump path and other options, by default, only below two options are required:

   - path /var/crash
   - core_collector makedumpfile -c -d 31

#. "service kdump restart" if the configuration file has been changed;
#. Trigger a dump:

   - echo "1" > /proc/sys/kernel/sysrq
   - echo "c" > /proc/sysrq-trigger

#. System will begin dump and reboot;
#. Check if vmcore file is generated under the kdump path;
#. Done.

iSCSI Server
--------------

iSCSI server can be configured with Targetcli, please refer to https://www.server-world.info/en/note?os=CentOS_Stream_9&p=iscsi&f=1


===================
kvm/qemu/libvirt
===================

Host/Node Information
-----------------------

::

  virsh nodeinfo

Auto Start a VM
----------------

::

  virsh dominfo test
  virsh autostart [--disable] test

Destroy a VM Clearly
------------------------

::

  virsh destroy test
  virsh undefine test
  virsh pool-refresh default
  virsh vol-delete --pool default <disk.qcow2>

Create a VM
--------------

::

  sudo virt-install \
  --name centos7 \
  --description "CentOS 7" \
  --ram=1024 \
  --vcpus=2 \
  --os-type=Linux \
  --os-variant=rhel7 \
  --disk path=/var/lib/libvirt/images/centos7.qcow2,bus=virtio,size=10 \
  --graphics none \
  --location $HOME/iso/CentOS-7-x86_64-Everything-1611.iso \
  --network bridge:virbr0  \
  --console pty,target_type=serial -x 'console=ttyS0,115200n8 serial'

Capture a screenshot
---------------------

::

  # screenshot is saved as ppm file which needs to be opened with special software(there exists online tools)
  virsh screenshot xxxx --file snap1.ppm

Edit VM live xml
------------------

::

  virsh edit test
  EDITOR=vim virsh edit test

Image Resize
--------------

::

  qemu-img resize /var/lib/libvirt/images/test.qcow2 +1G


Tune CPU
----------

::

  virsh setvcpus --domain test --maximum 2 --config
  virsh setvcpus --domain test --count 2 --config
  virsh reboot test
  virsh dominfo test

Tune Memory
------------

::

  virsh setmaxmem test 2048 --config
  virsh setmem test 2048 --config
  virsh reboot test
  virsh dominfo test

Copy Files to a VM
--------------------

::

  # create an iso image
  genisoimage -o data.iso <files/folder>
  # find target device
  virsh dumpxml <ID/Name> # get the target device name, e.g. hdb
  # attach the iso
  virsh attach-disk <ID/Name> /<absolute path>/data.iso hdb --sourcetype block --driver qemu --subdriver raw --type cdrom
  # Mount in the VM
  virsh console <ID/Name>
  lsblk # or lsscsi
  mount /dev/sr0 /mnt

libvirt cpuid definition verification
---------------------------------------

libvirt needs to understandard cpu features. To support this, src/cpu/cpu_map.xml is used.

To verify if a feature exists within vm, run cpuid from vm os:

- decode ebx='0x00000200' to binary as 0b1000000000
- cpuid -r -1 -l 7 # here 7 refers to eax_in='0x07'
- from cpuid output, decode ebx, say 0x209c03a9 to binary as 0b100000100111000000001110101001
- check 0b1000000000 & 0b100000100111000000001110101001, if it eauals to 0b1000000000, yes - feature enabled

::

  <feature name='erms'>
    <cpuid eax_in='0x07' ebx='0x00000200'/>
  </feature>

Non-interactive ops with vm
-------------------------------

::

  # login
  while : ; do
    pty=$(virsh ttyconsole $uuid)
    timeout 1 cat $pty > serial_log
    result=`tail -n 1 serial_log`

    if [[ $result =~ "login:"  ]]; then
      echo $username > $pty
      echo > $pty
      continue
    elif [[ $result =~ "Password:"  ]]; then
      echo $passwd > $pty
      echo  > $pty
      echo
    elif [[ $result =~ "root@"  ]]; then
      break
    else
      echo > $pty
    fi
    sleep 3
  done

  # reboot
  echo reboot > $pty
  echo > $pty

==========
cgroups
==========

list supported subsystems
---------------------------

::

  lssubsys [-am]
  lscgroup

control cpu usage with cpu
---------------------------

#. Install libcgroup-tools which provides CLI tools for using cgroups
#. Create a cgroup named cpulimit

   ::

     cgcreate -g cpu:/cpulimit

# . Set how much CPU resources processes can use within the cgroup

    - Example 1: use 10% of 1 x CPU

      ::

        # Explanation:
        # - cfs_period_us: the time period to measure CPU usage, max 1s and min 1000us
        # - cfs_quota_us: the time all processes within the cgroup can use within each cfs_period_us
        # Result: processes within the cgroup get cfs_quota_us / cfs_period_us * 100% of 1 x CPU resource
        #         in this example, it is 10% of all CPU resouces
        cgset -r cpu.cfs_period_us=1000000 cpulimit
        cgset -r cpu.cfs_quota_us=100000 cpulimit
        cgget -g cpu:cpulimit

    - Example 2: use 10% of all CPUs

      ::

        # Provided there are 8 x CPUs in total
        cgset -r cpu.cfs_period_us=1000000 cpulimit
        cgset -r cpu.cfs_quota_us=$(( 1000000 * 8 * 0.1 )) cpulimit
        cgget -g cpu:cpulimit

    - Example 3: use 100% of 2 x CPUs

      ::

        # Provided there are 8 x CPUs in total
        cgset -r cpu.cfs_period_us=1000000 cpulimit
        cgset -r cpu.cfs_quota_us=$(( 1000000 * 2 )) cpulimit
        cgget -g cpu:cpulimit

#. Start processes and put them under the control of the cgroup

   ::

     cgexec -g cpu:cpulimit command1
     cgexec -g cpu:cpulimit command2

control cpus process can use with cpuset
------------------------------------------

::

  cgcreate -g cpuset:/testset
  # cgset -r cpuset.cpus='0,2,4,6,8,10' testset
  # cgset -r cpuset.cpus='0-3' testset
  cgset -r cpuset.cpus=3 testset
  cgset -r cpuset.mems=0 testset
  cgexec -g cpuset:testset command

control block io
------------------

::

  # mount blkio if it is not mounted/enabled
  # mount -t cgroup -o blkio none /sys/fs/cgroup/blkio
  # echo "major:minor value > xxxx", where xxx is one of:
  # blkio.throttle.read_bps_device
  # blkio.throttle.write_bps_device
  # blkio.throttle.read_iops_device
  # blkio.throttle.write_iops_device

convert cgroup v1 to v2
--------------------------

::

  grubby --update-kernel=/boot/vmlinuz-5.4.119-19-0010 --args "systemd.unified_cgroup_hierarchy=1"
  reboot

move a process into a cgroup
------------------------------

::

  cgcreate -g cpu:mygroup
  # move a specified process into the cgroup
  nohup xxxx &
  pgrep xxxx # ge the process id of the process
  echo <pid of xxxx> | tee /sys/fs/cgroup/cpu/mygroup/cgroup.procs
  # move all processes started from current shell into the cgroup
  # $$ is the current shell pid, all processes started from current shell share the same cgroup
  echo $$ > /sys/fs/cgroup/cpu/mygroup/cgroup.procs


===================
kernel unsorted
===================

Unsorted kernel related hints, will be consolidated later.

Device I/O
-------------

I/O port -> I/O memory -> Memory mapped I/O(MMIO) -> DMA -> IOMMU

