---
tags: [git, cheatsheet]
aliases: ["git reference", "git config"]
type: cheatsheet
---
# Git Basics
## Reference

- Git tutorial: man gittutorial
- Pro Git: https://git-scm.com/docs
- Reset Demystified: https://git-scm.com/book/en/v2/Git-Tools-Reset-Demystified
- Git Branching: https://git-scm.com/book/en/v2/Git-Branching-Branches-in-a-Nutshell

## caret and tilde

- ref~ is shorthand for ref~1 and means the commit's first parent. ref~2 means the commit's first parent's first parent......
- ref^ is shorthand for ref^1 and means the commit's first parent. ref^2 means the commit's second parent......
- diagram as below:

  ```
           HEAD ------->+ Fifth commit on master
                        |
    HEAD~1 or HEAD^1 -->+ Merge branch
                        |\
          HEAD~1^2 -----|>+ First commit on branch
                        | |
   HEAD~2 or HEAD~1^1 ->+ | Fourth commit on master
                        | |
   HEAD~3 or HEAD~2^1 ->+/  Third commit on master
                        |
               etc.     + Second commit on master
                        |
                        + First commit on master
                        |
                        + ...etc.
  ```

## Revisions and Ranges

**man gitrevisions**

```bash
# leverage <refname>@{<date>} of gitrevisions
git diff master@{0} master@{1 day ago}
git log <commit 1>..<commit 2>
git log <commit 1>...<commit 2>
```

## Config

Below options are recommended before using git(without global for per repository based configuration):

```bash
# show all options: git config -l --show-origin
git config --global user.name "<First Name> <Second Name>"
git config --global user.email <email>
git config --global http.sslVerify false
git config --global core.editor vim
git config --global credential.helper cache
git config --global credential.useHttpPath true
git config --global format.pretty format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cd) %C(blue)<%aE>%Creset"
git config --global init.defaultBranch main
git config --global core.quotepath false
git config --global -l
```

Git configuration can also be edited with vim as below:

```bash
git config --global --edit
```

## Debug

```bash
export GIT_TRACE_PACKET=1
export GIT_TRACE=1
export GIT_CURL_VERBOSE=1
```

## Related
- [[git_reset_revert]]
- [[git_branch]]
- [[git_log_history]]
- [[git_diff]]

