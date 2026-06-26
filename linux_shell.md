---
tags: [linux, shell, cheatsheet]
aliases: ["bash shortcuts", "zsh", "shell shortcuts"]
type: cheatsheet
---
# Linux Shell & Shortcuts
## Command Editing Shortcuts

- Ctrl + a – go to the start of the command line
- Ctrl + e – go to the end of the command line
- Ctrl + b - move the cursor back one character
- Ctrl + f - move the cursor forward one character
- Ctrl + d - delete the character under cursor
- Ctrl + w – delete from cursor to start of word (i.e. delete backwards one word)
- Ctrl + k – delete from cursor to the end of the command line
- Ctrl + u – delete from cursor to the start of the command line
- Ctrl + y – paste word or text that was cut using one of the deletion shortcuts after the cursor
- Alt  + b – move backward one word (or go to start of word the cursor is currently on)
- Alt  + f – move forward one word (or go to end of word the cursor is currently on)
- Alt  + t – swap current word with previous
- Ctrl + t – swap character under cursor with the previous one
- Ctrl + backspace - delete a previous word (support path delimiter, such as /)

## Command Recall Shortcuts

- Ctrl + r – search the history backwards
- Ctrl + s - search the history forward(xon needs to be turned off: stty -ixon)
- Ctrl + g - quit the search
- Ctrl + p – previous command in history (i.e. walk back through the command history)
- Ctrl + n – next command in history (i.e. walk forward through the command history)
- Ctrl + o - execute current displayed command(repeatable)
- Alt + . – use the last word of the previous command

## Command Control Shortcuts

- Ctrl + l – clear the screen
- Ctrl + c – terminate the command
- Ctrl + z – suspend/stop the command
- Ctrl + s – freeze the terminal(stops the output to the screen)
- Ctrl + q – unfreeze the terminal(allow output to the screen)

## Freeze/unfreeze the terminal

NOTE: some terminal may not react for the shortcuts due to xon/xoff value.

```bash
stty -a | grep -E 'xon|xoff'
# turn on
stty ixon
# turn off
stty -ixon
```

- Ctrl + s - suspend/freeze the terminal, no input can be performed
- Ctrl + q - resume the terminal, input can be performed again

## Console resize

When using virsh console or a tty connection to some equipment, the console size is small to show all the texts within a line. There are several ways to adjust this:

- xterm-resize(preferred): just run "resize"
- stty: stty rows 45 ; stty columns 140; stty size
- export LINES=45 && export COLUMNS=163

## Show cursor icon

Sometimes, the terminal cursor icon for current input position may get lost:

```bash
tput cnorm
```

## Use 256 colors terminal

```bash
# anyone of below choices
export TERM=xterm-256color
export TERM=screen-256color
export TERM=tmux-256color
```

## Colour names

- Colours can be referred with names like "colourxxx";
- Frequent used 8 colors can also be referred as black, red, green, yellow, blue, magenta, cyan, white;
- Tool colortest(available on debian/ubuntu) can be used to show the effect of difference colors, e.g. colortest-8 to show effects of 8 colors when they are used as fg and bg;
- Builtin tput commands can be used to show colors:

  ```bash
  # man terminfo for references
  # setf/setb for 8 colors, setaf/setab(set ascii foreground/background) for 256 colors
  # foreground
  for c in {0..255}; do tput setaf $c; tput setaf $c | cat -v; echo =colour$c; done
  # background
  for c in {0..255}; do tput setab $c; tput setab $c | cat -v; echo =colour$c; done
  ```

## List Shortcuts/Bindings

- sh/bash

  ```bash
  help bind
  bind -p
  bind -p | grep '^"\\C-'
  bind -p | grep '^"\\e'
  (\C-: Ctrl +, \e: meta/Alt +)
  ```

- zsh

  ```bash
  man zshzle
  bindkey -l
  bindkey -M <keymap name>
  bindkey -M emacs | grep '^\"\^'
  bindkey -M emacs | grep -i '^\"^\['
  ```

## Long Command Edit/edit-command-line

- export EDITOR='vim'
- \<Ctrl+x\>\<Ctrl+e\>
- :wq

## Change Line Editing Mode

- bash: set -o vi
- zsh : bindkey \<-e|-v\>

## Command Quick Substitution

- ^string1^string2^     - Repeat the last command, replacing string1 with string2. Equivalent to !!:s/string1/string2/
- !!gs/string1/string2/ - Repeat the last command, replacing all string1 with string2
- Refer to: https://www.gnu.org/software/bash/manual/bashref.html#History-Interaction

## Special glob

```bash
# 1. match files, directories and subdirectories
# "*" matches all files and directories(without subdirectories);
# "**" matches all files and directories and their subdirectories;
# bash support
shopt globstar
shopt -s globstar
# zsh support
setopt extendedglob # prerequisite
setopt GLOB_STAR_SHORT
unset GLOB_STAR_SHORT
# 2. respect/ignore case
# bash support - no such function w/ bash
# zsh support
setopt extendedglob # prerequisite
setopt CASE_GLOB
unsetopt CASE_GLOB
```

## Loop

### Single line for loop with background jobs

```bash
# & is enough, if &; is used, an error will be triggered
# refer to https://unix.stackexchange.com/questions/91684/use-ampersand-in-single-line-bash-loop
for((i=1;i<=255;i+=1)); do echo $i; /opt/app1 & done
```

### for loop a range

```bash
for i in {1..10}; do
  echo $i
done
for i in `seq 1 10`; do
  echo $i
done
round=10
for i in `seq 1 $round 2`; do
  echo $i
done
```

## zsh tips

### Common

- zsh reference card: http://www.bash2zsh.com/zsh_refcard/refcard.pdf
- zsh tips: http://grml.org/zsh/zsh-lovers.html

### zsh set/unset options

```bash
setopt # Display all enabled options
setopt HIST_IGNORE_ALL_DUPS
unsetopt # Display all off options
unsetopt HIST_IGNORE_ALL_DUPS
```

## Run jobs in background

### Wait jobs

```bash
while : ; do
    pids=""
    <process 1/command 1>  &
    pids="$pids $!"
    ……  &
    <process N/command N> &
    pids="$pids $!"
    for id in $pids; do
        wait $id
        echo $?
    done
done
```

### Run a shell function with nohup

```bash
abc () {
  while : ; do
    echo "hello"
    sleep 1
  done
}
export -f abc
nohup bash -c "abc" >/dev/null 2>&1 &
```

## Fork implementation with shell

There are 2 x formats to achive forking with shell:

1. Through a function

   ```bash
   function abc() { xxx; xxx; ... }
   abc &
   ```

2. Through an anonymous function

   ```bash
   (xxx; xxx; ...) &
   ```

## Shell debugging

```bash
#!/bin/bash -xvT
# important: using single quote + insert "export PS4=xxx" into the script but not from CLI
# set PS4 to print script filename, line num., func name
export PS4='+(${BASH_SOURCE}:${LINENO}):${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
# or with only script filename and lineno
# export PS4='${BASH_SOURCE}:${LINENO}: '
# --- OR ---
#!/bin/bash
set -o errexit
set -o xtrace
set -o functrace
export PS4='+(${BASH_SOURCE}:${LINENO}):${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
```

## String Contains in Bash

- Leverage Wildcard

  ```bash
  if [[ "$string" == *"$substring"*  ]]; then
    echo "'$string' contains '$substring'"
  else
    echo "'$string' does not contain '$substring'"
  done
  ```

- Leverage Regular Expression

  ```bash
  if [[ "$string" =~ $substring  ]]; then
    echo "'$string' contains '$substring'"
  else
    echo "'$string' does not contain '$substring'"
  fi
  ```

## Create an array based on command output

```bash
a1=( $(ps -T -o pid,tid,psr,comm -p `pgrep -f 92e50bee-568d-4cc9-ad5a-617a6eb8206e` | grep CPU | awk '{print $2}' ) )
echo ${a[*]}
```

## autoexpect

- expect scripts can be leveraged for automation interactive CLI based tasks. But it is tedious to write such a script.
- autoexpect can be used to generating the initial expect script more quickly.

## Related
- [[linux_text_tools]]
- [[linux_system]]

