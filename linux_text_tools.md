---
tags: [linux, cheatsheet, text-processing]
aliases: ["awk", "sed", "grep", "find", "text tools"]
type: cheatsheet
---
# Linux Text & File Tools
## hex editor

- hexedit: View and edit files in hexadecimal or in ASCII, especially useful for checking raw disk/file. Refer to https://github.com/pixel/hexedit
- ImHex: A Hex Editor for Reverse Engineers, Programmers. Refer to https://github.com/WerWolv/ImHex

## Binary/raw data view/edit

### Tools

- xxd: hexdump or reverse
- hexdump: ASCII, decimal, hexadecimal, octal dump
- od: dump in octal, decimal, hexadecimal, integer, etc.
- hexedit: view and edit files in hex or ASCII, refer to https://github.com/pixel/hexedit

### Examples

- Generate a random unsigned decimal 2-byte integer

  ```bash
  od -vAn -N2 -tu2 < /dev/urandom
  ```

- Search file content with a raw disk

  ```bash
  # hexdump -C can also be used
  # hexedit can also be used
  xxd /dev/sda | grep <ASCII string>
  ```

- Change file contents from a raw disk

  ```bash
  # man hexedit to find the commands supported by hexedit
  hexedit /dev/sdc
  ```

## manpage toc

Based on the level of title you want to see, below commands can be used(3 stands for 3 x levels of titles).

```bash
man ovs-vsctl | grep '^ \{0,3\}[A-Z]'
```

## Here Document

Here document in shell is used to feed a command list(multiple line of strings) to an interactive program or a command, such as ftp, cat, ex.

It has 2 x forms:

- Respect leading tabs(but not spaces): <<EOF
- Suppress leading tabs: <<-EOF

### Use a variable containing multiple lines of string

```bash
lines=`ls -l /etc`
echo $lines # if lines contains special words, signs, this may not work
echo "$lines" # this always works
```

### Redirect here document output

```bash
{
   mongo 192.168.1.101/ycsb <<EOF
   use ycsb;
   sh.status(true);
   EOF
}  | tee -a /tmp/output
```

### Avoid variable interpretation

- Use quote:

  ```bash
  cat > /tmp/a.sh <<"EOF"
  var1=$( ls -l )
  for i in $(seq 1 10); do
    echo $i
  done
  EOF
  ```

- Use escape: variables w/o escaping will still be interpreted

  ```bash
  cat > /tmp/a.sh <<EOF
  var1=\$( ls -l )
  for i in \$(seq 1 10); do
    echo \$i
  done
  EOF
  ```

## read

### Here String

**<<<** is here string, a form of here document. It is used as: COMMAND <<< $WORD, where $WORD is expanded and fed to the stdin of COMMAND.

Sample:

```bash
while read -r line; do
command1
command2
......
done <<< "$variable_name"
```

### Respect leading and trailing whitespace

```bash
IFS= read -r abc
# if abc is "   hello   "
# IFS= will make read respect them, so abc will be "   hello   "
# without IFS=, abc will be "hello"
echo $abc
```

### Define a variable containing multiple lines of string

**Note**: a variable should be enclosed in double quotes while referring to it, otherwise, it will be treated as a single line string due to the shell expansion.

```bash
read -d '' var_name <<-EOF
line1
...
EOF
echo "$var_name"
```

### Read from multiple files within one loop

```bash
USRF="users.txt"
ATTRF="attributes.txt"

while read USR; do
  read -r GENDER <&3
  read -r AGE <&3
  echo "$USR:$GENDER:$AGE"
done <$USRF 3<$ATTRF
```

## awk

### Built-in Variables

- FS : input field separator
- OFS: output field separator
- RS : record separator
- ORS: output record separator
- NF : number of fields
- NR : number of records

### Common Command Format

```bash
awk '
   BEGIN { actions }
   /pattern/ { actions }
   /pattern/ { actions }
   .....
   END { actions }
' filenames
```

### awk define variables

-v \<variable name\>=\<variable value\>

Examples:

```bash
awk -v name=Jerry 'BEGIN{printf "Name = %s\n", name}'
awk -F= -v key=$1 '{if($1==key) print $2}'
Notes:
  1. The first $1 is the first shell positional parameter;
  2. The second $1, and the following $2 is the first and second column/field of a input record.
```

### Get lines whose fields/columns is a special word

```bash
awk '$7=="some_word" {for(i=1;i<=NF;++i){printf "%s ", $i}; printf "\n"}'
```

### Get lines whose fields/columns match a special word

```bash
awk '$7~/some_word/ {for(i=1;i<=NF;++i){printf "%s ", $i}; printf "\n"}'
```

### Output a range of fields

```bash
awk '{for(i=3;i<=8;++i){printf "%s ", $i}; printf "\n"}'
```

### Calculate the sum of a column

```bash
awk '{sum += $3}END{print sum}'
```

### Calculate duplicate rows with hash

```bash
# column 1 is used as the key, and calculate the sum when it is the same
awk '{cnt[$1] += $2}END{for (k in cnt) print k, cnt[k]}'
```

### Get the last 2 columns

```bash
ping -c 100 localhost | awk '/time=/{print $(NF-1), $NF}'
```

## Find

### Find and sort by time

```bash
find . -type f -printf '%T@ %p\n' | sort -k 1 -n [-r]
```

### Find files newer than

```bash
find . -type f -newermt '2021-02-05'
find -newermt "$(date '+%Y-%m-%d %H:%M:%S' -d '10 minutes ago')"
```

### Find files and show their contents together with file names

```bash
find /sys/kernel/mm/hugepages/hugepages-2048kB/ -type f -print0 | xargs -0 -r grep .
find . -type f -name "*.sh" -print0 | xargs -0 -n1 grep -H 'hello world'
```

### Exclude paths

```bash
# NOTES:
# -path for glob
# -regex for regular expression
# ./ prefix is a must
# /* suffix is a must
find . -type f ! -path ./samples/* ! -path ./Documentation/*
find /proc/ ! -regex '/proc/[0-9]+/*'
```

### Delete broken links

```bash
find /etc/apache2 -type l ! -exec test -e {} \; -print | sudo xargs rm
```

### Find files which are executable

```bash
find /path/to/directory -type f -perm /u+x,g+x,o+x
find /path/to/directory -type f -executable
```

## Change file attributes

```bash
# use chattr to make a file append only, immutable(cannot be deleted), etc.
lsattr abc
chattr +i abc
chattr -i abc
```

## Command line calculation with bc

By default, bash does not support floating point calculation. For example, below expressions are not valid:

```bash
# [[]] does not support floating point
A=100.1
B=100.1
if [[ $A -eq $b ]]; then
  echo "Equal"
fi

# $(()) does not support floating point
$((A + B))
```

To calculate floating point with bash, use bc as below:

```bash
bc -l <<< "scale=10; $A == $B"
bc <<< "scale=10; $A + $B"
```

## Recode file to UTF-8

- recode -f UTF-8 \<file name\>

- Get driver name

  ```bash
  [root@LPAR2 ~]# lspci -k
  …...
  f7:01.0 Ethernet controller: Intel Corporation 82576 Gigabit Network Connection (rev 01)
          Subsystem: Intel Corporation Device 0000
          Kernel driver in use: igb
          Kernel modules: igb
  ```

## lsof tips

- lsof \<file\> ---> Which processes are using the file
- lsof +D \<directory\> ---> Which processed are accessing the directory, and which files under the directory are being accessed
- lsof -nP -i :80 ---> which process is listening on a specific port

## tail tips

By default, tail -f follows a file based on the file descriptor. Once the file is rotated, the file descript gets changed, tail -f will stop working.

```bash
tail -f /path/to/file # if file descriptor never changes
tail --follow=name --retry /path/to/file # if file may get rotated which lead to fd changes
```

## head and tail together

```bash
cat /etc/passwd | (head; echo; tail)
```

## Process the new line character

- Delete trailing new line

  ```bash
  tr -d '\n'
  ```

- Change trailing new line to some other character

  ```bash
  tr '\n' ','
  ```

## Use shell variable in sed

```bash
sed -i -e "s/bindIp:.*$/bindIp: $IP_ADDR/" /etc/mongod.conf
```

## Make grep match for only 1 time

```bash
grep -m1 …...
```

## grep with multiple patterns

```bash
grep -E 'a|b|c|d|e'
grep -e 'a' -e 'b' -e 'c' -e 'd' -e 'e'
grep -v -e 'a' -e 'b' -e 'c' -e 'd' -e 'e'
```

## grep non greedy match

```bash
# the default and extended(-E) grep does not support non greedy match,
# perl mode(-P) should be used
ps -ef | grep qemu-system-x86_64 | grep -Po 'bdf=.*?,'
```

## Posix regular expression definitions

```bash
man 7 regex
```

## Print section between two regular expressions with sed

```bash
sed -n -e '/reg1/,/reg2/p' <file>
```

## Remove unprintable characters from a file with sed

```bash
sed -e 's/[^[:print:]]//g' /path/to/file
```

## Change soft link with sed

```bash
sed -i --follow-symlinks ...
```

## Sort based on several fields

```bash
sort -k <field 1 order> -k <field 2 ordr> ... [-n] [-r]
```

## Sort with a random order

```bash
cat /etc/passwd | shuf
```

## Preserve colors with less

```bash
rg task_struct | less -R
```

## Tarball with xz

xz is a newer compression tool than gz, bz, bz2, etc. It delivers better compression ratio and performance.

```bash
tar -cJf <archive.tar.xz> <files>
```

## Split large files

```bash
split -d -b 100M file_name file_name.
cat `ls file_name.*` > file_name
```

## Join multiple lines into one

```bash
# paste -sd
cat /etc/passwd | sed 's/:.*$//' | paste -sd '|'
```

## Related
- [[linux_shell]]

