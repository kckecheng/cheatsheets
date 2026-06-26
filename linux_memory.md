---
tags: [linux, cheatsheet, memory]
aliases: ["memory", "hugepage", "slab", "oom"]
type: cheatsheet
---
# Linux Memory
## Operations on memory

### Check slab information

```bash
slabtop
cat /proc/slabinfo
vmstat -m
```

### Check page allocator statistics

```bash
# page allocator is actully the buddy system
cat /proc/buddyinfo
cat /proc/pagetypeinfo
```

### Check memory watermark

```bash
cat /proc/zoneinfo
```

### Cache line info

```bash
getconf -a | grep CACHE_LINESIZE
```

### Check overcommit config

```bash
cat /proc/sys/vm/overcommit_memory
cat /proc/sys/vm/overcommit_ratio
```

### Check/Adjust oom score

```bash
cat /proc/<pid>/oom_score
cat /proc/<pid>/oom_score_adj
echo -1000 > /proc/<pid>/oom_score_adj
```

### Check vmalloc address info

```bash
cat /proc/vmallocinfo
```

### Check memory space address info

```bash
cat /proc/iomem
```

## Random number

### Get a simple random int within a range

```bash
# use shuf
N=$(shuf -i 1-100 -n 1)
echo $N
# use RANDOM
echo $RANDOM
```

### Get pseudo random numbers in binary, decimal, hex, etc.

```bash
# od supports output format as character, decimal, unsigned decimal, hex, etc.
# xxd, hexdump also supports similar functions with their specific focus, man xxd|hexdump
od -vAn -N2 -tu2 < /dev/urandom
```

### Randomness test

```bash
# FIPS 140-2 tests
rngtest -c 1000000 </dev/urandom
# Diehard - https://webhome.phy.duke.edu/~rgb/General/dieharder.php
# diehard -g -l
cat /dev/urandom | diehard -g 200 -a
```

## Calculate the size of hugepage used by a specified process

```bash
# say the huge page size is 2M
grep -B 11 'KernelPageSize:     2048 kB' /proc/[PID]/smaps | grep "^Size:" | awk 'BEGIN{sum=0}{sum+=$2}END{print sum/1024}'
```

## Calculate used huge pages of a system

```bash
# say the huge page size is 2M
nr=`cat /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages`
free=`cat /sys/kernel/mm/hugepages/hugepages-2048kB/free_hugepages`
used=$((nr - free))
echo $((used*2))M;
echo $((used*2/1024))G
```

## Related
- [[linux_process_cpu]]
- [[linux_hardware]]

