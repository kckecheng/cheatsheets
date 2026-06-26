---
tags: [git, cheatsheet, stash]
aliases: ["git stash"]
type: cheatsheet
---
# Git Stash
## git stash

git stash temporarily shelves (or stashes) changes you've made to your working copy so you can work on something else, and then come back and re-apply them later on.

### Stash

Command:
  **git stash [push [-u] [-a] [-m \<message\>]]**

Options:

- -u: include untracked files
- -a: include ignored files

Example:

```bash
git status
git stash push -a -m stash1
git list
```

### Re-apply

There are several options to re-apply stashed changes:

- Re-apply the latest stashed changes, and remove the changes from the stash:

  ```bash
  git stash pop
  ```

- Re-apply the latest stashed changes but keep the changes in the stash:

  ```bash
  git stash apply
  ```

- Re-apply a specified stashed changes:

  ```bash
  git stash list
  git stash <pop|apply> <stash name, such as stash@1>
  ```

### View diffs

```bash
git stash show -p stash@{0}
```

### Cleanup

```bash
git stash drop [stash name]
--- OR to clean all stashes ---
git stash clear
```

### Create a branch based on a stash

```bash
git stash branch abc stash@{1}
git switch abc
# check files at the timestamp when the stash is created
git switch -f master
git branch -D abc
```

## Related
- [[git_basics]]
- [[git_branch]]

