---
tags: [git, cheatsheet, diff]
aliases: ["git diff"]
type: cheatsheet
---
# Git Diff
## diff diagram

```
Working Directory   <------+------+------+
        |                  |      |      |
        |               diff HEAD |      |
        V                  |      |      |
     git add               |      |   git diff
        |                  |      |      |
        |                  |      |      |
        V                  |      |      |
      Index   <-----+------|------|------+
        |           |      |      |
        |     diff --cached|      |
        V           |      |      |
     git commit     |      |      |
        |           |      |      |
        |           |      |      |
        V           |      |      |
       HEAD   <-----+------+      |
        |                         |
        |                       diff HEAD^
        V                         |
previous "git commit"             |
        |                         |
        |                         |
        V                         |
      HEAD^   <-------------------+
```

## Compare 2 x repos

```bash
diff -x '.git*' -Naur --no-dereference <repo1 directory> <repo2 directory>
```

## Show diff introduced by a merge

```bash
git show -m <commit id>
git show --first-parent <commit id>
git diff <commit id>^ <commit id>
```

## git diff

### show differences with vimdiff

```bash
git difftool -t vimdiff [-y] [--cached]
```

### diff between different branches

```bash
git diff master origin/master
```

### diff between files from different branches

```bash
git diff <branch name1>..<branch name2> -- <abs/rel path to a file or file glob like target-i386/cpu.[ch]>
--- OR ---
git diff <branch name1>:<abs path(./) to a file> <branch name2>:<abs path to the same file>
```

### diff between a forked local branch and the original upstream

```bash
git remote add upstream <url of the original upstream branch>

git fetch upstream
--- OR ---
git remote update

git branch -a ---> the original upstream branch will be shown

git diff master upstream/master ---> compare local(forked) and the upstream
--- OR ---
git log master..upstream/master

git merge upstream/master ---> merger original upstream differences to local
```

### diff w/ file globs

```bash
# without using glob, a patch containing all changes can be created
git diff <commit x>..<commit y> > test.patch
# all .c and .h files under current directory
git diff <commit x id> <commit y id> -- *.[ch]
# all .c and .h files under current directory and all subdirectories recursively(globstar)
git diff <commit x id>..<commit y id> -- **/*.[ch]
```

### diff between current(HEAD) and git fetch

After running *git fetch*, it is good to have a look at what will be changed after merge. Under such condition, below commands help:

```bash
git diff HEAD...origin/master
--- OR FOR SHORT ---
git diff ...origin/master
```

### diff with time info

Refer to *man gitrevisions* for how to specify date time info.

```bash
git diff HEAD 'HEAD@{3 weeks ago}' -- <file/dir name>
git diff "master@{0}" "master@{25 hours ago}"
```

## Related
- [[git_basics]]
- [[git_merge]]

