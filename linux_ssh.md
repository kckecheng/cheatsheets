---
tags: [linux, cheatsheet, ssh, network]
aliases: ["ssh", "sshd", "ssh key"]
type: cheatsheet
---
# Linux SSH
## ssh

### ssh client configuration

1. Configuration file: ~/.ssh/config(mode 400, and create if it does not exist);
2. man ssh_config to find all supported options;
3. Format:

   ```
   Host <host pattern, such as *, ip, fqdn>
       <Option Name> <Option Value>
       ......
   --- OR ---
   Host <host pattern, such as *, ip, fqdn>
       <Option Name>=<Option Value>
       ......
   ```

4. Examples:

   - Disable host key checking:

     ```
     Host *
         StrictHostKeyChecking no
         UserKnownHostsFile /dev/null
     ```

   - Use ssh v1 only

     ```
     Host *
         Protocol 1
     ```

### Add ssh public key to remote servers

To configure key based ssh login, the ssl public key (generated with ssh-keygen -t rsa) needs to be copied and appended to the file **~/.ssh/authorized_keys** on remote servers.

Command **ssh-copy-id** can be leveraged to do the work automatically.

### Enable Additional SSH Key Algorithms

When ssh to some equipment, errors as below may be prompted:

```
no matching key exchange method found. Their offer: xxx, yyy
```

To login such equipment:

```bash
ssh -oKexAlgorithms=+xxx <user>@<equipment>
```

### Run multiple Remote Commands with SSH

```bash
# ssh <user>@<host> ""
ssh root@192.168.10.10 "while : ; do top -b -o '+%MEM' | head -n 10; echo; sleep 3; done"
ssh root@192.168.10.10 "while : ; do top -b -o '+%MEM' | head -n 10; echo; sleep 3; done"
ssh root@192.168.10.10 "vmstat -w -S m 5 10"
ssh root@192.168.10.10 "while :; do docker stats --no-stream; echo; sleep 5; done"
```

### ssh login with a private key

```bash
# make sure the permission of a private key is configured as 400 or 600
ssh -i /path/to/private/key/pem root@xxx.xxx.xxx.xxx
```

### Run commands without password by using sshpass

```bash
# if multiple commands are used, they can be formated as "command1 && echo && command2 && ..." or "command1; command2; ..."
sshpass -p <password> ssh -p <port> -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=5 -o LogLevel=error <IP> '<commands>'
```

### Verify ssh password with a loop with sshpass

```bash
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
```

## Related
- [[linux_system]]
- [[net_basics]]

