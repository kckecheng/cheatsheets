---
tags: [git, cheatsheet]
aliases: ["git misc", "git credential", "lazygit"]
type: cheatsheet
---
# Git Miscellanea
## Cache Credential

1. Store credential on disk in plaintext

   ```bash
   git config [--global] credential.helper store
   ```

2. Cache in memory only

   ```bash
   # Cache for 15 x minutes by default
   git config --global credential.helper cache
   # Specify timeout
   git config --global credential.helper 'cache --timeout=3600'
   ```

## Overwrite local files with git pull

This should only be used when there are too many conflicts to solve during a normal merge operation.

```bash
git fetch --all
git reset --hard <FETCH_HEAD | branch name, such as origin/master>
git pull
```

## Clean untracked local files

```bash
git clean -f # Remove file
git clean -df # Remove both files and directories
git clean -xdf # Remove files, directories, and ignored files and directories
git clean -f -e abc -x # Remove files and excluding pattern abc
```

## git rm multiple files

```bash
git add -u
```

## Remove a file in index

```bash
git rm --cached <file path>
```

## Shallow clone

Pull just the latest commits, not the entire repo history which improve clone performance(but w/o history):

```bash
git clone --depth 1 https://gitlab.gnome.org/GNOME/glib.git
git clone --depth X ...
```

## git proxy

```bash
# use https.proxy for https
git config [--global] http.proxy http://proxyuser:proxypwd@proxy.server.com:8080
git config [--global] http.proxy 'socks5://127.0.0.1:8080'
git config [--global] --unset http.proxy
# use env vars, use https_proxy for https
export http_proxy=http://proxyuser:proxypwd@proxy.server.com:8080
export http_proxy=socks5://127.0.0.1:8080
export no_proxy="localhost,127.0.0.1,localaddress,.localdomain.com"
unset http_proxy
```

## git delta

git delta is a powerful pager for git diff/show/log. Refer to https://github.com/dandavison/delta for configuration. If it is not provided within the distribution repositories, install it with homebrew.

```bash
git config -l
git -c delta.side-by-side=false show <commit id>
```

## lazygit

Terminal UI for git, great for viewing git log.

```bash
go install github.com/jesseduffield/lazygit@latest
lazygit
```

## Related
- [[git_basics]]

