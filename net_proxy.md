---
tags: [network, cheatsheet, proxy]
aliases: ["xray", "socks5", "http proxy"]
type: cheatsheet
---
# Network Proxy
## Proxy

### Environment variable

```bash
# if all_proxy is set, there is no need to set others
# using ALL_PROXY, HTTP_PROXY, etc. if lower case do not work
export all_proxy=socks5://127.0.0.1:10800
export http_proxy=http://xxx:xxx
export https_proxy=$http_proxy
export ftp_proxy=$http_proxy
export rsync_proxy=$http_proxy
export no_proxy='www.test.com,127.0.0.1,2.2.2.2'
```

### SOCKS5 Proxy with xray

Installation:

```bash
# xray needs to be installed on both server and client side
# reference: https://github.com/XTLS/Xray-install
# install/uninstall w/ the official script on the server side
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ remove
# install with homebrew(recommended) on the client side
brew install xray
```

Configuration:

```json
# Server side:
{
    "log": {
        "loglevel": "warning"
    },
    "inbounds": [
        {
            "port": 443,
            "listen": "0.0.0.0",
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": "xxxxxxxxxxxx",
                        "flow": "xtls-rprx-vision",
                        "level": 0
                    }
                ],
                "decryption": "none"
            },
            "streamSettings": {
                "network": "tcp",
                "security": "reality",
                "realitySettings": {
                    "show": false,
                    "dest": "www.microsoft.com:443",
                    "xver": 0,
                    "serverNames": [
                        "www.microsoft.com"
                    ],
                    "privateKey": "privatekeyxxx",
                    "shortIds": [
                        "idxxx"
                    ]
                }
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom",
            "settings": {}
        }
    ]
}
```

```json
# Client side:
{
    "log": {
        "loglevel": "warning"
    },
    "inbounds": [
        {
            "port": 10443,
            "listen": "127.0.0.1",
            "protocol": "socks",
            "settings": {
                "udp": true,
                "userLevel": 8
            },
            "sniffing": {
                "enabled": true,
                "destOverride": [
                    "http",
                    "tls"
                ]
            }
        },
        {
            "port": 10080,
            "listen": "127.0.0.1",
            "protocol": "http",
            "settings": {}
        }
    ],
    "outbounds": [
        {
            "protocol": "vless",
            "settings": {
                "vnext": [
                    {
                        "address": "a.b.c.d",
                        "port": 443,
                        "users": [
                            {
                                "id": "xxxxxxxxxxxx",
                                "flow": "xtls-rprx-vision",
                                "level": 0,
                                "encryption": "none"
                            }
                        ]
                    }
                ]
            },
            "streamSettings": {
                "network": "tcp",
                "security": "reality",
                "realitySettings": {
                    "serverName": "www.microsoft.com",
                    "publicKey": "publickeyxxx",
                    "shortId": "idxxx",
                    "spiderX": "/"
                }
            },
            "tag": "proxy"
        },
        {
            "protocol": "freedom",
            "tag": "direct"
        }
    ],
    "routing": {
        "domainStrategy": "IPIfNonMatch",
        "rules": [
            {
                "type": "field",
                "ip": [
                    "geoip:cn",
                    "geoip:private"
                ],
                "outboundTag": "direct"
            }
        ]
    }
}
```

Usage:

```bash
# the server side(/usr/local/etc/xray/config.json)
systemctl enable xray
systemctl restart xray
# the client side(/home/linuxbrew/.linuxbrew/etc/xray/config.json)
brew services start xray
brew services list
export all_proxy=socks5://127.0.0.1:10808
```

### Language specific proxies

- flutter pub:

  ```bash
  export FLUTTERPATH="/usr/local/flutter/bin"
  ```

- go

  ```bash
  # GOPROXY="https://goproxy.cn,direct"
  export GOPROXY=https://goproxy.io
  ```

- nodejs npm + yarn:

  ```bash
  npm config set registry https://registry.npmmirror.com
  npm config get registry
  yarn config set registry https://registry.npmmirror.com
  yarn config get registry
  ```

- pip

  ```bash
  # with ~/.pip/pip.conf
  # [global]
  # index-url = https://pypi.tuna.tsinghua.edu.cn/simple
  # [install]
  # trusted-host = https://pypi.tuna.tsinghua.edu.cn
  pip config set global.index-url https://mirrors.aliyun.com/pypi/simple/
  pip config set install.trusted-host mirrors.aliyun.com
  pip config list
  ```

## Related
- [[net_basics]]

