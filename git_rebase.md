---
tags: [git, cheatsheet, rebase]
aliases: ["git rebase", "rebase"]
type: cheatsheet
---
# Git Rebase
## Clean up local history with rebase

With a branch, lots of commits may be made. But it will pollute the master branch(or other branch to merge into) history, which will make the project history not friendly enough for tracking and maintenance.

For example:

```
branch 'feature':             + -> D -> E
                             /
branch 'master' : A -> B -> C
```

When merge branch 'feature' into 'master', you will get below history:

```
branch 'master' : A -> B -> C -> D -> E
```

Commits 'D' and 'E' will both be populated into the master branch history. When there are a lots of commits(say hundreds of) from different branches merged into the master branch, the master branch's history is not readable at all.

To avoid that, 'rebase' at branch level before merge is recommended(rebase at the master branch directly is dangerous).

**Steps**

1. Here is the init status of 'master' and 'feature' branches:

   ```bash
   ~ $ git branch -a
     feature
   * master
   ~ $ git log --oneline --graph --decorate
   * 98a2cca (HEAD -> master) init

   ~ $ git switch feature
   Switched to branch 'feature'
   ~ $ git log --oneline --graph --decorate
   * 5935f6d (HEAD -> feature) delete handler dir
   * 419297f delte vars dir
   * dca50ce delete meta dir
   * 98a2cca (master) init
   ```

2. We want to consolidate the 3 x commits(5935f6d, 419297f, dca50ce) from 'feature' branch into one:

   ```bash
   ~ $ git rebase -i HEAD~3
   ```

3. git will open a window/file(with config option core.editor) to let you edit how to rebase the three commits(HEAD~3):

   ```
   pick dca50ce delete meta dir
   pick 419297f delte vars dir
   pick 5935f6d delete handler dir
   ```

4. Change it as below:

   ```
   r dca50ce delete meta dir
   f 419297f delte vars dir
   f 5935f6d delete handler dir
   ```

   Explanations:

   - r/reword: use the commit, but edit the commit message
   - f/fixup : merge this commit into the previous one and discard commit message

5. After quiting the file(vim :wq), you can change the commit message. Quite(:wq) again

   ```bash
   ~ $ git rebase -i HEAD~3
   [detached HEAD 35302fe] delete meta/default/handler dirs
    Date: Sat Sep 23 20:12:34 2017 +0800
    1 file changed, 57 deletions(-)
    delete mode 100644 meta/main.yml
   [detached HEAD 4847d34] delete meta/default/handler dirs
    Date: Sat Sep 23 20:12:34 2017 +0800
    3 files changed, 61 deletions(-)
    delete mode 100644 handlers/main.yml
    delete mode 100644 meta/main.yml
    delete mode 100644 vars/main.yml
   Successfully rebased and updated refs/heads/feature.

   ~ $ git log --oneline --graph --decorate
   * 4847d34 (HEAD -> feature) delete meta/default/handler dirs
   * 98a2cca (master) init
   ```

6. Then the 'feature' branch can be merged into 'master' elegantly:

   ```bash
   ~ $ git switch master
   Switched to branch 'master'
   ~ $ git log --oneline --graph --decorate --all
   * 4847d34 (feature) delete meta/default/handler dirs
   * 98a2cca (HEAD -> master) init

   ~ $ git merge feature
   Updating 98a2cca..4847d34
   Fast-forward
    handlers/main.yml |  2 --
    meta/main.yml     | 57 ---------------------------------------------------------
    vars/main.yml     |  2 --
    3 files changed, 61 deletions(-)
    delete mode 100644 handlers/main.yml
    delete mode 100644 meta/main.yml
    delete mode 100644 vars/main.yml

   ~ $ git log --oneline --graph --decorate
   * 4847d34 (HEAD -> master, feature) delete meta/default/handler dirs
   * 98a2cca init
   ~ $ git log --oneline --graph --decorate --all
   * 4847d34 (HEAD -> master, feature) delete meta/default/handler dirs
   * 98a2cca init
   ```

7. The 'feature' branch can be deleted:

   ```bash
   ~ $ git branch -d feature
   Deleted branch feature (was 4847d34).
   ~ $ git branch -a
   * master
   ```

## Related
- [[git_log_history]]
- [[git_cherry_pick]]
- [[git_reset_revert]]

