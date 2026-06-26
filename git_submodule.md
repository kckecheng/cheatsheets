---
tags: [git, cheatsheet, submodule]
aliases: ["git submodule"]
type: cheatsheet
---
# Git Submodule
## Submodule

### Clone a repo with submodules

1. Clone a repo including its submodules:

   ```bash
   git clone --recursive <repo url>
   ```

2. If a repository has already been cloned without --recursive:

   ```bash
   git submodule update --init --recursive
   ```

### Add a submodule

```bash
# "git submodule update" checks out a commit directly but not a symbolic reference to HEAD, hence
# "detached head" issue will be triggered. This can be worked around by specifying the branch to
# track while adding a submodule
# git submodule add <git external repo url to the submodule> [local path of the local repo]
git submodule add -b master <git external repo url to the submodule> [local path of the local repo]
git submodule init
```

### Update a submodule

```bash
git submodule update --rebase --remote
# OR
git submodule foreach git pull origin master
```

### Remove a submodule

1. Delete the relevant section from **.gitmodules** file;
2. git add .gitmodules;
3. Delete the relevant section from **.git/config**;
4. git rm --cached path_to_submodule;
5. rm -rf .git/modules/path_to_submodule;
6. git commit -m message;
7. rm -rf path_to_submodule.

### Pull submodules

1. Pull all changes including changes in submodules:

   ```bash
   git pull --recurse-submodule
   ```

2. Pull all changes for the submodules:

   ```bash
   git submodule update --remote [--recursive] [--merge]
   ```

### Execute a command on every submodule

Examples:

```bash
# the whole command will fail if the inner command hit an error,
# to work around the issue, use the ":" command
git submodule foreach 'command | :'
git submodule foreach [--recursive] 'git reset --hard'
git submodule foreach 'git pull origin master | :'
```

## Related
- [[git_basics]]

