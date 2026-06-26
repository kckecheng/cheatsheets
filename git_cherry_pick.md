---
tags: [git, cheatsheet]
aliases: ["git cherry-pick", "cherry pick"]
type: cheatsheet
---
# Git Cherry-Pick
## git cherry-pick

Apply the changes introduced by some existing commits. Always used to apply commits from one branch to another.

Sometimes, there will be conflicts, which need to be solved just like using merge. After solving the conflicts, use "git cherry-pick --continue" to continue the application, otherwise, use "git cherry-pick --abort" to bail of the step.

*Sample:*

```bash
❯ ls
a1.txt  a2.txt

❯ git branch -a
* features
master

  ❯ git log --oneline --graph --decorate
* 4e8ecbc (HEAD -> features) add a2.txt
* 3b5695a (master) add a1

❯ git switch master
Switched to branch 'master'

❯ ls -l
total 0
-rw-r--r-- 1 kc kc 0 Jun 29 09:13 a1.txt

❯ git cherry-pick -x 4e8ecbc
[master 182e923] add a2.txt
 Date: Fri Jun 29 09:13:43 2018 +0800
 1 file changed, 0 insertions(+), 0 deletions(-)
 create mode 100644 a2.txt

❯ ls
a1.txt  a2.txt

❯ git log --oneline --graph --decorate
* 182e923 (HEAD -> master) add a2.txt
* 3b5695a add a1

❯ git show 182e923
commit 182e923d0682490649487213086c1554b191834f (HEAD -> master)
Author: KC
Date:   Fri Jun 29 09:13:43 2018 +0800

    add a2.txt

(cherry picked from commit 4e8ecbc09f58d67e4d1802424832e7155decaf5c)

diff --git a/a2.txt b/a2.txt
new file mode 100644
index 0000000..e69de29
```

## Related
- [[git_log_history]]
- [[git_rebase]]

