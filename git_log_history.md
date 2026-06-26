---
tags: [git, cheatsheet]
aliases: ["git log", "git reflog", "git history"]
type: cheatsheet
---
# Git Log & History
## git log

- git log [--graph] [--decorate] [--date=relative] [branch name]
- git log [--graph] [--oneline] [--decorate] [branch name]
- git log --graph --oneline --decorate --all
- git log --since '2 days ago'
- git log --since '1 hour ago'
- git log --since='Jan 1 2024' --until='Jan 7 2024'
- git log --pretty=short --stat
- git log --format=full
- git log --format='%H %an %s' --graph
- git log --graph --oneline --decorate --author="[Aa]aron"
- git log --graph --oneline --decorate --author="aaron@gmail.com" -i
- git log --grep xxx # show commits whose commit messages contain xxx
- git log -S \<string\> [-p] [file]
- git log -G \<regex\> [-p] [file]
- git log -S \<string\> \<commit range starting\>..\<commit range ending\>
- git log --all
- git log --all -i --grep='xxx yyy' # find the commit with message xxx yyy
- git log [--stat | --name-status | --name-only] # show what file have been changed
- git log --follow tempest # show changes on a file/folder
- git log -p # changes with patch
- git show [--format=full] \<sha1 hash\>

## Move git HEAD

Origin status:

```bash
# git log --oneline --graph --all
* 3c02ffb add passwd
* 58c8cf7 add resolve file
* 80bebdb add host file
```

### Move backward

```bash
# git reset --hard 58c8cf7 (or git reset --hard HEAD^)
HEAD is now at 58c8cf7 add resolve file
# git log --oneline --graph --all
* 58c8cf7 add resolve file
* 80bebdb add host file
```

### Move forward

```bash
# git reflog
58c8cf7 HEAD@{2}: reset: moving to 58c8cf7
3c02ffb HEAD@{3}: commit: add passwd
......
# git reset --hard 3c02ffb
HEAD is now at 3c02ffb add passwd
# git log --oneline --graph --all
* 3c02ffb add passwd
* 58c8cf7 add resolve file
* 80bebdb add host file
```

## Search changes

- git blame: Show what revision and author last modified each line of a file

  - git blame \<file\>
  - git blame -s \<file\>

- git grep: Print lines matching a pattern

  - git grep 'string pattern'

- git log: search contents of commit or commit message

  - git log -S [-p] 'text string' [file]
  - git log -G [-p] 'regex' [file]
  - git log --grep xxx # show commits whose commit messages contain xxx

## Append changes to previous commit

```bash
git commit -a --amend
```

## Show commit hash for a tag

```bash
git show-ref --tags
git show-ref --abbrev=7 --tags
git show <tag name>
```

## Check if a commit is in a branch

```bash
git branch [-r] --contains <commit hash>
       --- OR ---
git branch -a --contains <commit hash>
```

## Restore a deleted branch

```bash
git reflog
git checkout -b <branch> <sha>
```

## git reflog

```bash
git reflog
git reflog show --all
git reflog show <branch name>
git reflog
```

## Related
- [[git_basics]]
- [[git_branch]]
- [[git_reset_revert]]
- [[git_rebase]]
- [[git_tag]]

