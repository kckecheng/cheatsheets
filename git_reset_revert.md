---
tags: [git, cheatsheet]
aliases: ["git reset", "git revert"]
type: cheatsheet
---
# Git Reset & Revert
## Reset

```
# reset - https://git-scm.com/blog/2011/07/11/reset.html
+----------------------------+-------+------+--------------------+
|                            | HEAD | Index | Work Dir | WD Safe |
+----------------------------+------+-------+----------+---------+
| Commit Level               |      |       |          |         |
+----------------------------+------+-------+----------+---------+
| reset --soft [commit]      | REF  |  NO   |    NO    |   YES   |
| reset [commit]             | REF  |  YES  |    NO    |   YES   |
| reset --hard [commit]      | REF  |  YES  |    YES   |   NO    |
| checkout [commit]          | HEAD |  YES  |    YES   |   YES   |
| restore -s [commit]        | HEAD |  YES  |    YES   |   YES   |
+----------------------------+----+-------+----------+-----------+
| File Level                 |      |       |          |         |
+----------------------------+------+-------+----------+---------+
| reset (commit) [file]      |  No  |  YES  |    NO    |   YES   |
| checkout (commit) [file]   |  No  |  YES  |    YES   |   NO    |
| restore -s (commit) [file] |  No  |  YES  |    YES   |   NO    |
+----------------------------+------+------+-----------+---------+
```

## revert/reset/switch

**git switch** is newly added to replace the branch switch functions of **git checkout**

- git revert   : creates a new commit that undoes changes from a previous commit; adds new history ;
- git switch   : (previously git checkout) checks out content from the repo and puts it under working directory; does not impact history;
- git reset    : modifies the index (staging area), or changes which commit a branch head is point at; may impact history;
- common rules :

  - if a commit has led to a change, and it is incorrect: "git revert" undoes the change, and record the action in history;
  - if files have been changed but have not been committed, "git restore" check out a fresh from repo copy of the files;
  - if a commit has been made but has not been shared to anyone, "git reset" rewrites the history so that it seems nothing has been changed.

## Related
- [[git_basics]]
- [[git_rebase]]
- [[git_log_history]]

