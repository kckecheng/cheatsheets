---
tags: [git, cheatsheet, merge]
aliases: ["git merge", "git mergetool", "merge conflict"]
type: cheatsheet
---
# Git Merge & Conflicts
## git mergetool

Generally speaking, 'git mergetool' will show conflicts in below format:

```
+--------------------------------+
| LOCAL  |     BASE     | REMOTE |
+--------------------------------+
|             MERGED             |
+--------------------------------+
```

**Usage:**

```bash
git config merge.tool vimdiff
git config merge.conflictstyle diff3
git merge <branch/commit/etc.>
git mergetool

Then:
  1. solve/edit conflicts between <<< and >>> -> delete <<<, === and >>> -> :wq
  2. git add *; git commit -m '<message>' --- OR --- git merge --continue
```

**Merge conflict markers:**

```
<<<<<<<
foo
=======
bar
>>>>>>>
```

- Normal Merge:

  - Top(between <<< and ===): local changes
  - Bottom(between === and >>>): upstream/remote changes

- Rebase Merge:

  - Top: upstream/remote changes
  - Bottom: local changes

## Select what to merge

During merge operations, there are situations only some files are supposed to be included.

1. Keep local files:

   ```bash
   # git checkout <local branch name> -- <file names>(deprecated, using git restore)
   git restore -s <local branch name> <file names>
   # OR for current branch
   git restore <file names>
   ```

2. Remove files added by the merge operations:

   ```bash
   git rm --cached <files>
   ```

3. Continue merge:

   ```bash
   git merge --continue
   ```

## Merge without generating a commit

This is similar as doing "Rebase and merge" with github:

```bash
git merge --no-commit --no-ff
```

## Related
- [[git_branch]]
- [[git_diff]]

