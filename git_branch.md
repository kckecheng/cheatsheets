---
tags: [git, cheatsheet, branch]
aliases: ["git branch", "git switch", "git pull"]
type: cheatsheet
---
# Git Branch & Switch
## Branch

**git switch** is the newly operation added recently, which focuses on branch switch ops in order to replace **git checkout**

- git remote update origin --prune ---> update the local list of remote branches
- git branch -a[v]
- git branch -a --sort=-committerdate ---> list all branches which have recent updates
- git branch \<name\>    ---> Create a branch
- git branch -d \<name\> ---> Delete a branch
- git branch -m \<name\> ---> Rename a branch
- git branch --contains=\<commit|tag\> ---> show all branches contain the commit|tag
- git checkout \<name\>  ---> Checkout a branch(deprecated)
- git checkout -b \<name\> == git branch \<name\> + git checkout \<name\>(deprecated)
- git switch \<name\>    ---> Switch to a branch (equals git checkout \<name\>)
- git switch -c \<name\> ---> Create and switch to the branch

## Pull

- git pull
- git pull -t ---> tags won't get updated sometimes, use -t to fetch them again

## Delete a remote branch

```bash
git push -d origin <branch name>
git branch -d <branch name>
```

## Update the local list of remote branches

```bash
git remote update origin --prune
```

## switch/pull/fetch/restore

### Restore a file from another branch

```bash
# Deprecated command: git checkout <branch name> -- <file name>
git restore -s <branch name> <file name>
(Note: prefix, such as origin/<branch name>, is needed when you want to checkout files from a remote branch)
```

### Check what has been changed without making any changes

```bash
git fetch --dry-run
git show <from> -> <to>
```

### Restore a file from a previous commit

```bash
# Deprecated command: git checkout <commit hash or HEAD~n> -- <file 1> <file 2> ...
git restore -s <commit hash or HEAD~n> <file 1> <file 2> ...
# do not change local file but create a new one
git show <commit hash or HEAD~n>:<file> | tee /tmp/xxx
```

### Overwrite all local files

```bash
git fetch --all
git reset --hard origin/master
git clean -dn
git clean -df
```

## Switch to a branch whose name exists on several remote refs

Error as below will be triggered when switch to a branch which exists on several remote refs:

```
error: pathspec 'unity_solaris' did not match any file(s) known to git.
```

Solution: switch with **--track** option as below:

```bash
# git remote update
# git branch -a                                                                                                           master
* master
remotes/origin/HEAD -> origin/master
remotes/origin/master
remotes/origin/unity_solaris
remotes/upstream/master
remotes/upstream/unity_solaris

# git switch --track origin/unity_solaris
```

## Related
- [[git_basics]]
- [[git_log_history]]
- [[git_merge]]

