.. contents:: Git Tips

=========
Git Tips
=========

Reference
---------

- Pro Git: https://git-scm.com/docs
- Reset Demystified: https://git-scm.com/book/en/v2/Git-Tools-Reset-Demystified
- Git Branching: https://git-scm.com/book/en/v2/Git-Branching-Branches-in-a-Nutshell

diff diagram
------------

::

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

Reset
-----

::

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

revert/reset/switch
-------------------

**git swtich** is newly added to replace the branch switch functions of **git checkout**

- git revert   : creates a new commit that undoes changes from a previous commit; adds new history ;
- git switch   : (previously git checkout) checks out content from the repo and puts it under working directory; does not impact history;
- git reset    : modifies the index (staging area), or changes which commit a branch head is point at; may impact history;
- common rules :

  - if a commit has led to a change, and it is incorrect: "git revert" undoes the change, and record the action in history;
  - if files have been changed but have not been committed, "git restore" check out a fresh from repo copy of the filess;
  - if a commit has been made but has not been shared to anyone, "git reset" rewrites the history so that it seems nothing has been changed.

caret and tilde
---------------

 - ref~ is shorthand for ref~1 and means the commit's first parent. ref~2 means the commit's first parent's first parent......
 - ref^ is shorthand for ref^1 and means the commit's first parent. ref^2 means the commit's second parent......
 - diagram as below:

   ::

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

Config
------

Below options are recommended before using git(without global for per repository based configuration):

  ::

    git config --global user.name "<First Name> <Second Name>"
    git config --global user.email <email>
    git config --global http.sslVerify false
    git config --global core.editor vim
    git config --global credential.helper cache
    git config --global credential.useHttpPath true
    git config --global format.pretty format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cd) %C(blue)<%aE>%Creset"
    git config --global -l

Git configuration can also be edited with vim as below:

  ::

    git config --global --edit

Debug
-----

::

  export GIT_TRACE_PACKET=1
  export GIT_TRACE=1
  export GIT_CURL_VERBOSE=1

Branch
------

**git switch** is the newly operation added recently, which foucses on branch switch ops in order to replace **git checkout**

- git branch -a[v]
- git branch <name>    ---> Create a branch
- git branch -d <name> ---> Delete a branch
- git branch -m <nmae> ---> Rename a branch
- git checkout <name>  ---> Checkout a branch(deprecated)
- git checkout -b <name> == git branch <name> + git checkout <name>(deprecated)
- git switch <name>    ---> Switch to a branch (equals git checkout <name>)
- git switch -c <name> ---> Create and switch to the branch

Pull
----

- git pull == git fetch + git merge

git log
-------

- git log [--graph] [--decorate] [--date=relative] [branch name]
- git log [--graph] [--oneline] [--decorate] [branch name]
- git log --graph --oneline --decorate --all
- git log --since '2 days ago'
- git log --since '1 hour ago'
- git log --pretty=short --stat
- git log --format=full
- git log --format='%H %an %s' --graph
- git log --graph --oneline --decorate --author="[Aa]aron"
- git log --graph --oneline --decorate --author="aaron@gmail.com" -i
- git show [--format=full] <sha1 hash>

git mergetool
-------------

Generally speakcing, 'git mergetool' will show conflicts in below format:

::

  +--------------------------------+
  | LOCAL  |     BASE     | REMOTE |
  +--------------------------------+
  |             MERGED             |
  +--------------------------------+

**Usage:**

::

  git config merge.tool vimdiff
  git config merge.conflictstyle diff3
  git merge <branch/commit/etc.>
  git mergetool

  Then:
    1. solve/edit conflicts between <<< and >>> -> delete <<<, === and >>> -> :wq
    2. git add *; git commit -m '<message>' --- OR --- git merge --continue

**Merge conflict markers:**

::

  <<<<<<<
  foo
  =======
  bar
  >>>>>>>

- Normal Merge:

  - Top(between <<< and ===): local changes
  - Bottom(between === and >>>): upstream/remote changes

- Rebase Merge:

  - Top: upstrea/remote changes
  - Bottom: local changes

Select what to merge
--------------------

During merge operations, there are situations only some files are supposed to be included.

1. Keep local files:

   ::

     # git checkout <local branch name> -- <file names>(deprecated, using git restore)
     git restore -s <local branch name> <file names>
     # OR for current branch
     git restore <file names>

2. Remove files added by the merge operations:

   ::

     git rm --cached <files>

3. Continue merge:

   ::

     git merge --continue

Cache Credentail
----------------

1. Store credential on disk in plaintext

   ::

     git config [--global] credential.helper store

2. Cache in memory only

   ::

     # Cache for 15 x minutes by default
     git config --global credential.helper cache
     # Specify timeout
     git config --global credential.helper 'cache --timeout=3600'

Move git HEAD
-------------

Origin status:

::

  # git log --oneline --graph --all
  * 3c02ffb add passwd
  * 58c8cf7 add resolve file
  * 80bebdb add host file

Move backward
+++++++++++++

::

  # git reset --hard 58c8cf7 (or git reset --hard HEAD^)
  HEAD is now at 58c8cf7 add resolve file
  # git log --oneline --graph --all
  * 58c8cf7 add resolve file
  * 80bebdb add host file

Move forward
++++++++++++

   ::

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

Switch between https and ssh
----------------------------

ssh to https
++++++++++++

::

  # git remote -v
  origin  git@github.com:USERNAME/REPOSITORY.git (fetch)
  origin  git@github.com:USERNAME/REPOSITORY.git (push)
  # git remote set-url origin https://github.com/USERNAME/REPOSITORY.git
  # git remote -v
  origin  https://github.com/USERNAME/REPOSITORY.git (fetch)
  origin  https://github.com/USERNAME/REPOSITORY.git (push)

https to ssh
++++++++++++

::

  # git remote -v
  origin  https://github.com/USERNAME/REPOSITORY.git (fetch)
  origin  https://github.com/USERNAME/REPOSITORY.git (push)
  # git remote set-url origin git@github.com:USERNAME/REPOSITORY.git
  # git remote -v
  origin  git@github.com:USERNAME/REPOSITORY.git (fetch)
  origin  git@github.com:USERNAME/REPOSITORY.git (push)

Log
---

Show changes on a file/folder
+++++++++++++++++++++++++++++

- git log --follow tempest
- git log --since '1 day ago' --follow tempest

Show changes with files
+++++++++++++++++++++++

- git log --stat
- git log --stat --follow tempest
- git log --stat --since '1 week ago' --follow tempest

Show change with diff
+++++++++++++++++++++

- git log -p
- git log -5 -p --stat

Show differences between commits/branches
+++++++++++++++++++++++++++++++++++++++++

- git log <since>..<until>, e.g.:

  ::

    git log origin/master..master
    git log remotes/origin/master..master

Show file changes between commits
+++++++++++++++++++++++++++++++++

- git log -p <-X|-n X> --follow <path>

  ::

    git log -p -1 --follow lib/modules/fio.py
    git log -p -n 1 --follow lib/modules/fio.py

Filter logs related with specified operations
+++++++++++++++++++++++++++++++++++++++++++++

Select only files that are:

- Added  : A
- Copied : C
- Deleted: D
- Renamed: R
- etc., refer to **man git-log**

::

  git log --diff-filter=<A|C|D|R|M|U|X>

Locate changes
--------------

- git blame: Show what revision and author last modified each line of a file

  - git blame <file>
  - git blame -s <file>

- git grep: Print lines matching a pattern

  - git grep 'string pattern'

- git log -S: Look for differences that change the number of occurrences of the specified string (i.e. addition/deletion) in a file

  - git log -S 'string pattern' <file>

Operations between a forked local branch and the original upstream
------------------------------------------------------------------

::

  git remote add upstream <url of the original upstream branch>

  git fetch upstream
  --- OR ---
  git remote update

  git branch -a ---> the original upstream branch will be shown

  git diff master upstream/master ---> compare local(forked) and the upstream
  --- OR ---
  git log master..upstream/master

  git merge upstream/master ---> merger original upstream differences to local

Append changes to previous commit
---------------------------------

::

 git commit -a --amend

Show commit hash for a tag
--------------------------

::

  git show-ref --tags
  git show-ref --abbrev=7 --tags
  git show <tag name>

Compare 2 x repos
-----------------

::

  diff -x '.git*' -Naur --no-dereference <repo1 directory> <repo2 directory>

Overwrite a remote ref
----------------------

When the local has been synced to the remote(git push), the local and remote will see the same refs(take it as history of commits). If the local refs are "rebase" after sync, git will show the two branches have 'diverged' - 'git push' will be rejected since 'rebase'.

To sync local to remote(overwrite remote refs with local):

::

  git push <-f|--force> <remote branch name> [local branch name]

Delete a remote branch
----------------------

::

  git push -d origin <branch name>
  git branch -d <branch name>

Update the local list of remote branches
----------------------------------------

::

  git remote update origin --prune

Overwrite local files with git pull
-----------------------------------

This should only be used when there are too many conflicts to solve during a normal merge operation.

::

  git fetch --all
  git reset --hard <FETCH_HEAD | branch name, such as origin/master>
  git pull

Clean untracked local files
---------------------------

::

  git clean -f # Remove file
  git clean -df # Remove both files and directories
  git clean -xdf # Remove files, directories, and ignored files and directories

switch/pull/fetch
-----------------

Restore a file from another branch
++++++++++++++++++++++++++++++++++

::

  # Deprecated command: git checkout <branch name> -- <file name>
  git restore -s <branch name> <file name>
  (Note: prefix, such as origin/<branch name>, is needed when you want to checkout files from a remote branch)


Check what has been changed without making any changes
++++++++++++++++++++++++++++++++++++++++++++++++++++++

::

  git fetch --dry-run
  git show <from> -> <to>

Restore a file from a previous commit
+++++++++++++++++++++++++++++++++++++

::

  # Deprecated command: git checkout <commit hash or HEAD~n> -- <file 1> <file 2> ...
  git restore -s <commit hash or HEAD~n> <file 1> <file 2> ...

Overwrite all local files
+++++++++++++++++++++++++++

::

  git fetch --all
  git reset --hard origin/master
  git clean -dn
  git clean -df

Switch to a branch whose name exists on several remote refs
-----------------------------------------------------------

Error as below will be triggered when switch to a branch which exists on several remote refs:

::

  error: pathspec 'unity_solaris' did not match any file(s) known to git.

Solution: switch with **--track** option as below:

::

  # git remote update
  # git branch -a                                                                                                           master
  * master
  remotes/origin/HEAD -> origin/master
  remotes/origin/master
  remotes/origin/unity_solaris
  remotes/upstream/master
  remotes/upstream/unity_solaris

  # git switch --track origin/unity_solaris

git diff
--------

show differences with vimdiff
+++++++++++++++++++++++++++++

::

  git difftool -t vimdiff [-y] [--cached]

diff between different branches
+++++++++++++++++++++++++++++++

::

  git diff master origin/master

diff between files from different branches
++++++++++++++++++++++++++++++++++++++++++

::

  git diff <branch name1>..<branch name2> -- <abs/rel path to a file>
  --- OR ---
  git diff <branch name1>:<abs path(./) to a file> <branch name2>:<abs path to the same file>
  --- OR ---
  git difftool <branch name1>:<abs path(./) to a file> <branch name2>:<abs path to the same file>

diff between commits
++++++++++++++++++++

::

  git log
  git diff <commit x id> <commit y id>
  git difftool -t vimdiff <commit x id> <commit y id> (use vimdiff to show diff)

diff between current(HEAD) and git fetch
++++++++++++++++++++++++++++++++++++++++

After running *git fetch*, it is good to have a look at what will be changed after merge. Under such condition, below commands help:

::

  git diff HEAD...origin/master
  --- OR FOR SHORT ---
  git diff ...origin/master

diff with time info
-------------------

Refer to *man gitrevisions* for how to specify date time info.

::

 git diff HEAD 'HEAD@{3 weeks ago}' -- <file/dir name>
 git diff "master@{0}" "master@{25 hours ago}"

Check if a commit is in a branch
--------------------------------

::

  git branch [-r] --contains <commit hash>
         --- OR ---
  git branch -a --contains <commit hash>

git rm multiple files
---------------------

::

  git add -u

Remove a file in index
----------------------

::

  git rm --cached <file path>

Merge without generating a commit
---------------------------------

This is similar as doing "Rebase and merge" with github:

::

  git merge --no-commit --no-ff

Clean up local history with rebase
----------------------------------

With a branch, lots of commits may be made. But it will pollute the master branch(or other branch to merge into) history, which will make the project history not friendly enough for tracking and maintenance.

For example:

::

  branch 'feature':             + -> D -> E
                               /
  branch 'master' : A -> B -> C

When merge branch 'feature' into 'master', you will get below history:

::

  branch 'master' : A -> B -> C -> D -> E

Commits 'D' and 'E' will both be populated into the master branch history. When there are a lots of commits(say hundres of) from different branches merged into the master branch, the master branch's history is not readable at all.

To avoid that, 'rebase' at branch level before merge is recommended(rebase at the master branch directly is dangerous).

Steps
+++++

1. Here is the init status of 'master' and 'feature' branches:

   ::

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

2. We want to consolidate the 3 x commits(5935f6d, 419297f, dca50ce) from 'feature' branch into one:

   ::

     ~ $ git rebase -i HEAD~3

3. git will open a window/file(with config option core.editor) to let you edit how to rebase the three commits(HEAD~3):

   ::

     pick dca50ce delete meta dir
     pick 419297f delte vars dir
     pick 5935f6d delete handler dir

4. Change it as below:

   ::

     r dca50ce delete meta dir
     f 419297f delte vars dir
     f 5935f6d delete handler dir

   Explanations:

   - r/reword: use the commit, but edit the commit message
   - f/fixup : merge this commit into the previous one and discard commit message

5. After quiting the file(vim :wq), you can change the commit message. Quite(:wq) again

   ::

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

6. Then the 'feature' branch can be merged into 'master' elegantly:

   ::

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

7. The 'feature' branch can be deleted:

   ::

     ~ $ git branch -d feature
     Deleted branch feature (was 4847d34).
     ~ $ git branch -a
     * master

Submodule
---------

Clone a repo with submodules
++++++++++++++++++++++++++++

1. Clone a repo including its submodules:

   ::

     git clone --recursive <repo url>

2. If a repository has already been cloned without --recursive:

   ::

     git submodule update --init --recursive

Add a submodule
+++++++++++++++

::

  # "git submodule update" checks out a commit directly but not a symbolic reference to HEAD, hence
  # "detached head" issue will be triggered. This can be worked around by specifying the branch to
  # track while adding a submodule
  # git submodule add <git external repo url to the submodule> [local path of the local repo]
  git submodule add -b master <git external repo url to the submodule> [local path of the local repo]
  git submodule init

Update a submodule
+++++++++++++++++++

::

  git submodule update --rebase --remote
  # OR
  git submodule foreach git pull origin master

Remove a submodule
++++++++++++++++++

1. Delete the relevant section from **.gitmodules** file;
2. git add .gitmodules;
3. Delete the relevant section from **.git/config**;
4. git rm --cached path_to_submodule;
5. rm -rf .git/modules/path_to_submodule;
6. git commit -m message;
7. rm -rf path_to_submodule.

Pull submodules
+++++++++++++++

1. Pull all changes including changes in submodules:

   ::

     git pull --recurse-submodule

2. Pull all changes for the submodules:

   ::

     git submodule update --remote [--recursive] [--merge]

Execute a command on every submodule
++++++++++++++++++++++++++++++++++++

Examples:

::

  # the whole command will fail if the inner command hit an error,
  # to work around the issue, use the ":" command
  git submodule foreach 'command | :'
  git submodule foreach [--recursive] 'git reset --hard'
  git submodule foreach 'git pull origin master | :'

git stash
---------

git stash temporarily shelves (or stashes) changes you've made to your working copy so you can work on something else, and then come back and re-apply them later on.

Stash
+++++

Command:
  **git stash [push [-u] [-a] [-m <message>]]**

Options:

- -u: include untracked files
- -a: include ignored files

Example:

::

  git status
  git stash push -a -m stash1
  git list

Re-apply
++++++++

There are several options to re-apply stashed changes:

- Re-apply the latest stashed changes, and remove the changes from the stash:

  ::

    git stash pop

- Re-apply the latest stashed changes but keep the changes in the stash:

  ::

    git stash apply

- Re-apply a specified stashed changes:

  ::

    git stash list
    git stash <pop|apply> <stash name, such as stash@1>

View diffs
++++++++++

- Show a summury of a stash:

  ::

    git stash show [stash name]

- Show detailed diffs of a stash:

  ::

    git stash show -p [stash name]

Cleanup
+++++++

::

  git stash drop [stash name]
  --- OR to clean all stashes ---
  git stash clear

tag
----

Tag is used as a mechanism for version release: each time a tag is created, a release (on github) is created.

Create a tag
+++++++++++++

- Lightweight tag

  ::

    git tag [-m <message>] <name> [commit]

- Annotated tag: recommended, it stores extra meta data for a tag

  ::

    git tag -a [-m <message>] <name> [commit]

List tags
++++++++++

::

  git tag

Checkout a tag
+++++++++++++++

::

  git checkout tags/<tag name>
  # Checkout the tag and create a new branch to avoid overwritten
  git checkout tags/<tag name> -b <branch name>

Push a tag to remote
+++++++++++++++++++++

git push will not push tags by default, hence it needs to be explicitly specified.

::

  git push origin <tag name>

Delte a tag
+++++++++++++
::

  # Delete local
  git tag -d <tag>
  # Delete remote
  git push --delete origin <tag>

Revisions and Ranges
--------------------

**man gitrevisions**

::

  # leverage <refname>@{<date>} of gitrevisions
  git diff master@{0} master@{1 day ago}

Create pull request from the CLI
--------------------------------

Leverage the tool hub, which can be found @https://github.com/github/hub

- Installation

  ::

    sudo pacman -S hub

- Configuration

  - example.com: your github or enterprise github https access url(without https://)
  - oauth_token: token generated for accessing the site

  ::

    git config --global --add hub.host example.com
    cat > ~/.config/hub<<EOF
    example.com:
      - user: user_name
        oauth_token:
        protocol: https
    EOF

- Usage:

  ::

    hub pull-request -b upstream:feature_branch

git cherry-pick
---------------

Apply the changes introduced by some existing commits. Always used to apply commits from one branch to another.

Sometimes, there will be conflicts, which need to be solved just like using merge. After solving the conflicts, use "git cherry-pick --continue" to continue the application, otherwise, use "git cherry-pick --abort" to bail of the step.

*Sample:*

  ::

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

Restore a deleted branch
------------------------

::

  git reflog
  git checkout -b <branch> <sha>

git reflog
----------

::

  git reflog
  git reflog show --all
  git reflog show <branch name>
  git reflog
