.. contents:: Linux Performance Tips

Linux Performance Tips
========================

Overall
----------

There is a great diagram, which is from www.brendangregg.com, showing misc tracing tools on Linux. Overall, it can be used as a common reference.

.. image:: images/linux_perf_and_trace_utils.png

top
-------

Top is installed on almost all Linux distributions by default for performance monitoring. Here are some tips of using top:

- Select the column for sort: by default "%CPU" is used for sort

  * Press "F": the first line shows the current sort filed which is "%CPU" by default
  * Press "Up/Down" to navigate: say move to "%MEM"
  * Press "Right", followed by "Enter" to select the field
  * Press "s" to set the field as the current sort field, the first line will indicate the changes
  * Press "ESC" or "q" to see the change

- Reverse sort: Press "R" to reverse the sort order based on the current sort field
- Highlight the sort field column:

  * Press "x" to highlight the current sort field
  * Press "b" to highlight the background of the current sort field

- Filter: press "o/O":

  * Show all filters: press "^O"
  * Clear all filter: press "="
  * Samples:

     * COMMAND=vim
     * %CPU>0.5
     * !COMMAND=vim

- Adavance filter: select multiple processes

  ::

    top -p `pgrep -d ',' -f "app1|app2|app3"`

slabtop, slabinfo
--------------------

Check kernel slab memory, refer to http://www.secretmango.com/jimb/Whitepapers/slabs/slab.html for slab introductions.

nmon
-------

A great tool to tune system performance, which can show statistics for CPU/memory/disks/kernel/etc.

htop
-------

Similar as the classic top, but much more powerful - it is interactive and ncurses-based, which support mouse operations on terminal.

iotop
--------

Show IO status by process.

iftop
--------

Display bandwidth usage including host to host (ip to ip) information.

nethogs
-----------

NetHogs is a small 'net top' tool. Instead of breaking the traffic down per protocol or per subnet, like most tools do, it groups bandwidth by process.

bwm-ng
---------

Bandwidth Monitor NG is a small and simple console-based live network and disk *io bandwidth* monitor for Linux, BSD, Solaris, Mac OS X and others.

cgroups
--------

Control process cpu usage
~~~~~~~~~~~~~~~~~~~~~~~~~~~

#. Install libcgroup-tools which provides cli tools for using cgroups
#. Create a cgroup named cpulimite:

   ::

     cgcreate -g cpu:/cpulimit

#. Set the process can use 10% of all CPU resouces

   ::

     # Explanation:
     # - cfs_period_us: the time period to measure CPU usage, max 1s and min 1000us
     # - cfs_quota_us: the time all processes within the cgroup can use within each cfs_period_us
     # Result: processes within the cgroup get cfs_quota_us / cfs_period_us * 100% CPU resources
     #         in this example, it is 10% of all CPU resouces
     cgset -r cpu.cfs_period_us=1000000 cpulimit
     cgset -r cpu.cfs_quota_us=100000 cpulimit
     cgget -g cpu:cpulimit

#. Start a process and put it under the control of the cgroup

   ::

     cgexec -g cpu:cpulimit YOUR_COMMAND

sysdig
---------

A powerful system and process troubleshooting tool.

- Common options

  - sudo sysdig -cl
  - sudo sysdig -i <chisel name>
  - sudo sysdig -c <chisel name>
  - sudo sysdig -l
  - sudo csysdig

- Examples: https://github.com/draios/sysdig/wiki/sysdig-examples

systemtap
------------

SystemTap is a tracing and probing tool that allows users to study and monitor the activities of the computer system (particularly, the kernel) in fine detail. It provides information similar to the output of tools like netstat,  ps, top, and iostat, but is designed to provide more filtering and analysis options for collected information.

The advantage of systemtap is you can write a kind of script called **SystemTap Scripts** to perform complicated tracing. Please refer to https://sourceware.org/systemtap/ for details.

strace
---------

Trace system calls and signals

ftrace
---------

Ftrace is an internal tracer designed to help out developers and designers of systems to find what is going on inside the kernel. It can be used for debugging or analyzing latencies and performance issues that take place outside of user-space.

**event tracing**

::

  # method 1 - through event toggle
  cd /sys/kernel/debug/tracing/
  cat available_events # list all availabel events which can be traced
  ls events # list all available events which is organized in groups
  echo 1 > events/path/to/event/enable # enable the event tracing, multiple events can be traced
  echo 1 > tracing_on
  echo > trace
  cat trace # check trace results
  # method 2 - through set_event
  echo > set_event # clear previous events
  echo "event1" > set_event # multiple event tracing: echo "event2" >> set_event
  echo 1 > tracing_on
  echo > trace
  cat trace

**event filtering**

::

  # event filter
  cat events/path/to/event/format # understand the supported event format
  echo "filter expression" > events/path/to/event/filter
  echo 0 > events/path/to/event/filter # clear the filter
  # event subsystem filter
  cd events/subsystem/path
  echo 0 > filter
  echo "filter expression" > filter

**event pid filtering**

::

  cd /sys/kernel/debug/tracing
  echo <PID> > set_event_pid # filtering multiple PIDs: echo <PID1> <PID2> <...> >> set_event_pid
  ...

**function tracing**

::

  cat available_tracers # list all available traces, function, function_graph are used most frequently
  # function
  echo function > current_tracer
  cat available_filter_functions # get filters which can be used for function tracing
  echo <available filter> > set_ftrace_filter # multiple filter can be used - echo <another filter> >> set_ftrace_filter
  echo > trace
  cat trace # check trace results
  # function graph
  echo function_graph > current_tracer
  cat available_filter_functions # get filters which can be used for function graph tracing
  echo <available filter> > set_graph_function # multiple filter can be used - echo <another filter> >> set_graph_function
  echo 10 > max_graph_depth
  echo > trace
  cat trace # check trace results

**trace_pipe**

::

  # trace_pipe only contains newer data compared with last read, suitable for redirection
  cat trace_pipe
  cat trace_pipe > /tmp/trace.log

blktrace
-----------

1. **blktrace** is a block layer IO tracing mechanism which provides detailed information about request queue operations up to user space. The trace result is stored in a binary format, which obviously doesn't make for convenient reading;
2. The tool for that job is **blkparse**, a simple interface for analyzing the IO traces dumped by blktrace;
3. However, the plaintext trace result generated by blkparse is still not quite easy for reading, another tool **btt** can be used to generate misc reports, such as latency report, seek time report, etc;
4. Besides, a tool named **Seekwatcher** can be used to genrate graphs for blktrace, which will help a lot comparing IO patterns and performance;
5. In the meanwhile, **btrecord** and **btreplay** can be used to recreate IO loads recorded by blktrace.

perf-tool
------------

Performance analysis tools based on Linux perf_events (aka perf) and ftrace:

- bitesize
- cachestat
- execsnoop
- funccount
- funcgraph
- funcslower
- functrace
- iolatency
- iosnoop
- killsnoop
- kprobe
- opensnoop
- perf-stat-hist
- reset-ftrace
- syscount
- tcpretrans
- tpoint
- uprobe

Example 1: Scheduler Analysis

::

  # Record all scheduler events within 1 second
  perf sched record -- sleep 1
  # To check detailed events
  perf script [--header]
  # Summarize scheduler latencies by task
  perf sched latency [-s max]

Example 2: Performance Analysis

::

  # the whole system performance stat
  perf stat record -a sleep 10
  perf kvm stat record -a sleep 10
  # specified vcpu performance
  perf kvm stat record -a -p <vcpu tid> -a sleep 10
  # report
  perf stat report
  perf kvm stat report

Example 3: perf trace

::

  # trace a process
  perf trace record --call-graph dwarf -p $PID -- sleep 10
  # trace a group of processes
  mkdir /sys/fs/cgroup/perf_event/bpftools/
  echo 22542 >> /sys/fs/cgroup/perf_event/bpftools/tasks
  echo 20514 >> /sys/fs/cgroup/perf_event/bpftools/tasks
  perf trace -G bpftools -a -- sleep 10
