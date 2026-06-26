---
tags: [git, cheatsheet, tag]
aliases: ["git tag"]
type: cheatsheet
---
# Git Tags
## tag

Tag is used as a mechanism for version release: each time a tag is created, a release (on github) is created.

### Create a tag

- Lightweight tag

  ```bash
  git tag [-m <message>] <name> [commit]
  ```

- Annotated tag: recommended, it stores extra meta data for a tag

  ```bash
  git tag -a [-m <message>] <name> [commit]
  ```

### List tags

```bash
git tag
# list tags with additional information such as date
git tag --list --format='%(creatordate:short):  %(refname:short)'
# show annotation lines, w/o -n, annotation won't be shown
git tag -n
git tag -n100
git tag -l -n
```

### Checkout a tag

```bash
git checkout tags/<tag name>
# Checkout the tag and create a new branch to avoid overwritten
git checkout tags/<tag name> -b <branch name>
```

### Push a tag to remote

git push will not push tags by default, hence it needs to be explicitly specified.

```bash
git push origin <tag name>
```

### Delete a tag

```bash
# Delete local
git tag -d <tag>
# Delete remote
git push --delete origin <tag>
```

### Update remote tags

```bash
git fetch --tags --prune [--all]
```

### List commits between tags

```bash
git log tag1..tag2 | wc -l
```

### List commits which have tags

```bash
git log --decorate --simplify-by-decoration
git log --tags --no-walk
```

## Related
- [[git_log_history]]
- [[git_basics]]

