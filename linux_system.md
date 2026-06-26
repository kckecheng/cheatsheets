---
tags: [linux, cheatsheet, systemd, system-config]
aliases: ["systemd", "journalctl", "chrony", "kdump"]
type: cheatsheet
---
# Linux System & Services
## Auto start

### Run a script during system boot

To run a script automatically during system boot, rc.local, bash profile, etc. can be leveraged. However, customized systemd service nowadays is much better for the same purpose.

1. Define a customized systemd service:

   - Create a plain text file under /etc/systemd/system as below, name it as route_add.service for example:

     ```ini
     [Unit]
     Description=Add customized ip routes
     After=network.service

     [Service]
     Type=oneshot
     ExecStart=/usr/local/bin/route_add.sh

     [Install]
     WantedBy=multi-user.target
     ```

   - Refer to manpage systemd.service and systemd.unit for the detailed explanations on each parameters.

2. Create the actual script, such as /usr/local/bin/route_add.sh in our example, and assign exec permission with chmod a+x /usr/local/bin/route_add.sh
3. Enable and run it:

   ```bash
   systemctl enable route_add.service
   systemctl start route_add.service
   ```

### Run a script during system boot and keep it running

A service Type can be defined as oneshot, simple, forking, etc. When it is needed to keep a script running in the background forever, **forking** can be leveraged as below.

```bash
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
```

**Notes**: **fork** needs to be implemented by the app or the script to be executed.

## systemd

### Show service definition

```bash
systemctl cat xxx
systemctl show xxx
```

### List services/sessions/slices

```bash
# man systemd: to find all supported types
systemctl list-units --type=service
systemctl list-units --type=scope
systemctl list-units --type=slice
systemd-loginctl list-sessions
ls /run/systemd/sessions
```

### Control and check session

```bash
ls /run/systemd/system
cat /run/systemd/system/session-3598362.scope
systemd-loginctl list-sessions
systemd-loginctl show-session xxx
systemd-loginctl terminate-session xxx
```

## journalctl

### Check service logs based on time window

```bash
systemctl | grep '<service name>' ---> locate the service unit name
journalctl -S <time stamp> -u <service name>
```

### Check latest logs

```bash
journalctl -f ---> As tail
```

### Do not wrap log lines

```bash
journalctl --all --output cat -u <service name>
```

### Clean logs

```bash
journalctl --flush --rotate
journalctl --vacuum-time=1s
```

### Show logs related with a specific process

```bash
journalctl _PID=`pidof pal`
```

### Show logs for specified boot

```bash
journalctl --list-boots
journalctl -b <index, such as 0, -1, etc.> -e
```

### Show logs for syslog identifiers

```bash
journalctl -t vhost-user -t systemd -b0
```

## Who is on the server

```bash
# who is on the server
who [...]
# who is on the server and what they are doing
w [...]
```

## Disable auto logout for CLI console

```bash
# add to /etc/profile to persistent the setting
export TMOUT=0
```

## Disable IPv6

- sysctl

  - Add below contents in /etc/sysctl.conf

    ```
    net.ipv6.conf.all.disable_ipv6 = 1
    net.ipv6.conf.default.disable_ipv6 = 1
    net.ipv6.conf.lo.disable_ipv6 = 1
    ```

  - sysctl -p
  - cat /proc/sys/net/ipv6/conf/all/disable_ipv6 ===> If output is 1, IPv6 has been disabled. If not, try reboot the server.
  - Delete the IPv6 localhost definition entry from /etc/hosts
  - Regenerate the initial ram disk (initrd) on RHEL/CentOS: "dracut -f"

- Grub: add "ipv6.disable=1" to the linux line

  ```
  linux   /boot/vmlinuz-xxx xxx xxx ipv6.disable=1
  ```

## sudoers: \<user\> ALL = (\<user to act as\>) \<commands\>

```bash
Examples:
  # User "alan" can run commands "/bin/ls" and "/bin/kill" as user "root", "bin" or group "operator", "system"
  alan   ALL = (root, bin : operator, system) /bin/ls, /bin/kill
  # User "superadm" can run all commands as anyone
  superadm  ALL=(ALL)   ALL
  # User "adm" can sudo run all "root"'s commands without password'
  adm ALL = (root) NOPASSWD:ALL
  # Users in group "wheel" can run all commands as anyone
  %wheel ALL=(ALL) ALL
```

## Grub2 change boot order

**NOTE**: grubby is recommended if it is available.

```bash
awk -F\' '$1=="menuentry " {print i++ " : " $2}' /etc/grub2.cfg
grub2-editenv list
grub2-set-default 2
grub2-editenv list
```

## Disable console log

```bash
# dmesg -n 1
```

## Assign hostname dynamically with DHCP

1. **option host-name** can be used to assign a hostname while assigning IP - https://www.isc.org/wp-content/uploads/2017/08/dhcp41options.html;
2. **dhcp-eval** can be leveraged to generate a hostname dynamically - https://www.isc.org/wp-content/uploads/2017/08/dhcp41eval.html.

## Change System Clock

timedatectl is a new utility, which comes as a part of systemd system and service manager, a replacement for old traditional date command used in sysvinit daemon.

```bash
timedatectl list-timezones
timedatectl set-timezone Asia/Shanghai
```

## Change System Locale

```bash
# some locales such as zh_CN.utf8 need additional langpacks
# yum search langpack
# yum search languagepack
locale -a
export LC_ALL=en_US.utf8
```

## Disable Windows PATH with WSL

```bash
# create /etc/wsl.conf with below contents within a wsl distribution
[interop]
appendWindowsPath = false
# restart the wsl distribution
wsl --shutdown
wsl -d Ubuntu
```

## Manpages db update

if apropos, man -k give no results:

```bash
# run either of below based on your distribution
makewhatis
mandb
```

## Change password non-interactive

```bash
echo 'root:password' | chpasswd
```

## Reload configuration file without restarting service

SIGHUP as a notification about terminal closing event does not make sense for a daemon, because deamons are detached from their terminal. So the system will never send this signal to them. Then it is common practice for daemons to use it for another meaning, typically reloading the daemon's configuration.

```bash
kill -s HUP <daemon pid>
```

## Use Chrony for time sync

Modern Linux distributions start to use Chrony as the default application for time sync (NTP) instead of the classic ntpd. Chrony comes with 2 x programs:

- chronyd: the background daemon
- chronyc: CLI interface

Usage:

- Configuration (/etc/chrony.conf or /etc/chrony/chrony.conf) (Chrony NTP server and client use the same configuration)

  ```bash
  # Define the NTP server sources
  server 192.168.16.22 iburst

  # If it is configured as a NTP server, enable below options
  # Serve time even if not synchronized to a time source.
  #local stratum 0
  # Allow NTP client access from local network.
  #allow 192.168.0.0/16
  ```

- Start the service

  ```bash
  systemctl enable chronyd.service
  systemctl start chronyd.service
  ```

- Check NTP sources

  ```bash
  chronyc sources -v
  ```

- Check current time sync status

  ```bash
  chronyc tracking
  ```

- If time has been synced, it will be reflected from command "timedatectl"
- To sync time immediately

  ```bash
  chronyc makestep
  ```

## kdump config

1. Install "kernel-debuginfo-common" and "kernel-debuginfo", by default, these two packages are not kept in yum repository, they need to be downloaded from internet;
2. Install "kexec-tools" and "crash":

   - yum install kexec-tools
   - yum install crash

3. Edit grub.cfg, append "crashkernel=yM@xMparameter " to kernel:

   - Y : memory reserved for dump-capture kernel;
   - X : the beginning of the reserved memory;
   - This can be done with command: grubby --update-kernel=ALL --args="crashkernel=yM@xM";
   - "crashkernel=yM@0" or "crashkernel=yM" should be used if kdump service cannot start;

4. It is also recommended to configure multiple options together: crashkernel=0M-2G:128M,2G-6G:256M,6G-8G:512M,8G-:768M
5. Reboot and check with command: cat /proc/iomem | grep 'Crash kernel';
6. Configure /etc/kdump.conf to set dump path and other options, by default, only below two options are required:

   - path /var/crash
   - core_collector makedumpfile -c -d 31

7. "service kdump restart" if the configuration file has been changed;
8. Trigger a dump:

   - echo "1" > /proc/sys/kernel/sysrq
   - echo "c" > /proc/sysrq-trigger

9. System will begin dump and reboot;
10. Check if vmcore file is generated under the kdump path;
11. Done.

## iSCSI Server

iSCSI server can be configured with Targetcli, please refer to https://www.server-world.info/en/note?os=CentOS_Stream_9&p=iscsi&f=1

## Related
- [[linux_shell]]
- [[linux_hardware]]

