=======
tcpdump
=======

tcpip HEAD and tcpdump options
------------------------------

- https://www.sans.org/security-resources/tcpip.pdf

Main Options
------------

::

  -i any    : listen on all interfaces
  -i eth0   : listen on a specified interface
  -D        : show available interfaces
  -n        : do not resovle hostname
  -nn       : do not resove hostname and port names
  -q        : less verbose
  -t        : human-readable timestamp
  -tttt     : maximally human-readable timestamp
  -X        : show the packet’s contents in both hex and ASCII
  -v/vv/vvv : verbose
  -c        : get x number of packets
  -s        : define the snaplength (size) of the capture in bytes, -s0 for everything
  -S        : Print absolute sequence numbers

Logic and Grouping
------------------

- and / &&
- or  / ||
- not / !
- ()

Examples
--------

::

  # tcpdump -ttttvvnnS

  # tcpdump host 1.2.3.4

  # tcpdump -nnvXS -s0 -c1 icmp

  # tcpdump src 2.3.4.5.
  # tcpdump dst 3.4.5.6

  # tcpdump net 1.2.3.0/24

  # tcpdump port 3389
  # tcpdump src port 3389

  # tcpdump icmp

  # tcpdump portrange 21-23

  # tcpudmp less 32
  # tcpdump greater 64
  # tcpdump <=128

  # tcpdump -nnvvS src 10.5.2.3 and dst port 3389

  # tcpdump -nvX src net 192.168.0.0/16 and dst net 10.0.0.0/8 or 172.16.0.0/16

  # tcpdump dst 192.168.0.2 and src net and not icmp

  # tcpdump src 10.0.2.4 and (dst port 3389 or 22)

  # tcpdump 'src 10.0.2.4 and (dst port 3389 or 22)'
