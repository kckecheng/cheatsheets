---
tags: [linux, cheatsheet]
aliases: ["openssl", "nfs", "ipv6 ipv4"]
type: cheatsheet
---
# Linux Miscellanea
## Record and replay linux CMD screen

```bash
script --timing=file.tm script.out

cmd1
cmd2
...
exit

scriptreplay --timing file.tm --typescript script.out
```

## Check nfs IO stat

```bash
nfsstat -l
```

## Use openssl to download a certificate

```bash
openssl s_client -showcerts -connect <IP or FQDN>:<Port> </dev/null 2>/dev/null | openssl x509 -outform PEM > ca.pem
```

## Setup CA with OpenSSL

This tip only lists the most important commands for easy reference. For more information, refer to the [original doc](https://gist.github.com/soarez/9688998).

**Applicant Part:**

- Generate an RSA private key for CA:

  ```bash
  openssl genrsa -out example.org.key 2048
  ```

- Inspect the key:

  ```bash
  openssl rsa -in example.org.key -noout -text
  ```

- Extract RSA public key from the private key:

  ```bash
  openssl rsa -in example.org.key -pubout -out example.org.pubkey
  openssl rsa -in example.org.pubkey -pubin -noout -text
  ```

- Generate a CSR (Certificate Signing Request):

  ```bash
  openssl req -new -key example.org.key -out example.org.csr
  openssl req -in example.org.csr -noout -text
  ```

**CA Part:**

- Generate a private key for the root CA:

  ```bash
  openssl genrsa -out ca.key 2048
  ```

- Generate a self signed certificate for the CA:

  ```bash
  openssl req -new -x509 -key ca.key -out ca.crt
  ```

- Sign the applicant CSR to generate a certificate:

  ```bash
  openssl x509 -req -in example.org.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out example.org.crt
  openssl x509 -in example.org.crt -noout -text
  ```

- Verify the serial number assigned:

  ```bash
  cat ca.srl
  openssl x509 -in example.org.crt -noout -text | grep 'Serial Number' -A1
  ```

- Verify the certificate:

  ```bash
  openssl verify -CAfile ca.crt example.org.crt
  ```

## Bind to both ipv4 and ipv6 with all addresses

```bash
bind 0.0.0.0 # bind to all ipv4
bind ::0 # bind to all ipv6
bind 0.0.0.0 ::0 # bind to both ipv4 and ipv6
bind 0.0.0.0:80 ::0:80 # bind to the 80 port
bind 0.0.0.0:80 :::80 # bind to the 80 port
```

## Show timestamp within history output

```bash
help history
export HISTTIMEFORMAT="%F %T "
history
```

## Related
- [[linux_system]]
- [[linux_ssh]]

