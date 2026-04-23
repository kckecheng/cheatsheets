# Linux 内核崩溃转储（vmcore）分析完整指导手册

> **版本**: v1.0  
> **适用场景**: 服务器/系统宕机、kernel panic、kernel oops、soft/hard lockup、hung task、MCE 硬件异常、系统崩溃原因排查  
> **前置条件**: 已安装 `crash` 工具，具备与 vmcore 版本匹配的 `vmlinux`（含调试符号）

---

## 目录

1. [分析流程总览](#1-分析流程总览)
2. [Crash 工具基础](#2-crash-工具基础)
3. [第一步：基础信息收集](#3-第一步基础信息收集)
4. [第二步：加载内核源码（可选）](#4-第二步加载内核源码可选)
5. [第三步：硬件异常检查](#5-第三步硬件异常检查)
6. [第四步：软件异常检查](#6-第四步软件异常检查)
7. [第五步：子系统定向检查](#7-第五步子系统定向检查)
8. [第六步：输出分析报告](#8-第六步输出分析报告)
9. [快速参考：常见场景分析示例](#9-快速参考常见场景分析示例)
10. [调试技巧速查](#10-调试技巧速查)
11. [附录 A：x86_64 内核内存布局](#附录-a-x86_64-内核内存布局)
12. [附录 B：定制内核源码与热补丁定位](#附录-b-定制内核源码与热补丁定位)

---

## 1. 分析流程总览

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         vmcore 分析标准流程                              │
├─────────────────────────────────────────────────────────────────────────┤
│  ① 基础信息收集  →  ② 加载内核源码（可选） →  ③ 硬件异常检查            │
│       ↓                                                              │
│  ④ 软件异常检查（硬件检查未判定时执行）                                   │
│       ↓                                                              │
│  ⑤ 子系统定向检查（网络/存储相关时执行）                                  │
│       ↓                                                              │
│  ⑥ 输出标准化分析报告                                                   │
└─────────────────────────────────────────────────────────────────────────┘
```

**核心原则**：
- **严格按顺序执行**，禁止跳过硬件检查直接进行软件分析
- 若硬件异常检查判定为硬件异常，可直接终止分析并输出报告
- 所有 `crash` 命令使用 heredoc 格式，必须包含 `quit` 命令

---

## 2. Crash 工具基础

### 2.1 启动方式

```bash
crash -s --no_crashrc vmlinux* vmcore <<EOF
<commands>
quit
EOF
```

- `-s`：静默模式，减少冗余输出
- `--no_crashrc`：不加载用户自定义配置，确保输出一致性
- `vmlinux*`：使用通配符匹配带调试符号的内核镜像

### 2.2 常用命令速查

| 命令 | 用途 |
|------|------|
| `sys` | 显示系统基本信息（内核版本、主机名、宕机时间） |
| `sys -i` | 显示 DMI/BIOS 信息 |
| `bt` | 显示当前任务的调用堆栈 |
| `bt -f` | 显示完整堆栈帧信息 |
| `ps` | 显示所有进程状态 |
| `log` / `log \| tail -N` | 查看内核日志 |
| `dis <addr>` | 反汇编指定地址 |
| `dis -r <addr>` | 反汇编并显示参考地址附近的指令 |
| `dis -l <addr>` | 反汇编并显示源码行号 |
| `p /x $<reg>` | 以十六进制打印寄存器值 |
| `rd <addr>` | 读取内存内容 |
| `rd -8 <addr> <n>` | 以 8 字节为单位读取 n 个值 |
| `pte <addr>` | 查看页表项 |
| `vtop <vaddr>` | 虚拟地址转物理地址 |
| `kmem -i` | 查看内存使用概况 |
| `kmem -s` | 查看 slab cache 信息 |
| `kmem -V` | 查看内存统计变量 |
| `kmem <addr>` | 检查 slab 对象状态 |
| `task <pid>` | 查看指定进程的任务结构 |
| `files <pid>` | 查看进程打开的文件 |
| `vm <pid>` | 查看进程虚拟内存映射 |
| `runq` | 查看运行队列 |
| `dev` | 查看设备信息 |
| `net` / `net -s` / `net -a` | 查看网络设备/socket/协议栈 |
| `mount` | 查看挂载的文件系统 |
| `struct <name> <addr>` | 解析结构体 |
| `sym <name>` | 查找符号地址 |
| `help -t` | 查看内核变量 |
| `foreach bt` | 批量查看所有进程的调用栈 |

---

## 3. 第一步：基础信息收集

**必须在分析开始时首先执行**，收集的信息供后续所有步骤使用。

### 3.1 第一步 A：收集基础信息和 panic_processor 编号

```bash
crash -s --no_crashrc vmlinux* vmcore <<EOF
sys
p /x $rip
p /x $rsp
p /x $rbp
bt
log | tail -100
help -t | awk -F: '/panic_processor/{print $2}'
sys -i | grep DMI_BIOS_VERSION
quit
EOF
```

| 命令 | 收集的信息 |
|------|-----------|
| `sys` | 内核版本、主机名、宕机时间 |
| `p /x $rip/rsp/rbp` | 宕机时的指令指针、堆栈指针、帧基址 |
| `bt` | 完整函数调用链和执行路径 |
| `log \| tail -100` | 宕机日志，提取宕机类型 |
| `help -t \| awk ...` | 触发 panic 的逻辑 CPU 编号 |
| `sys -i \| grep DMI_BIOS_VERSION` | BIOS 版本 |

### 3.2 第一步 B：收集处理器详细信息

用第一步 A 获取的 `panic_processor` 编号替换 `<panic_processor>` 后执行：

```bash
crash -s --no_crashrc vmlinux* vmcore <<EOF
p cpu_info:<panic_processor> | sed -n 's/x86_model_id =/  x86_model_id:/p' | sed -e 's/\000//g' -e 's/\s*",$//'
pd cpu_info:<panic_processor> | sed -n "s/.*\\(phys_proc_id\\) = \\(.*\\),/\\2/p"
px cpu_info:<panic_processor> | grep microcode
quit
EOF
```

| 命令 | 收集的信息 |
|------|-----------|
| `p cpu_info:<N> ...` | 处理器型号 |
| `pd cpu_info:<N> ...` | 物理核心编号（十进制） |
| `px cpu_info:<N> \| grep microcode` | 触发宕机 CPU 的微码版本 |

### 3.3 需要记录的关键信息

| 信息项 | 来源 |
|--------|------|
| **内核版本** | `sys` 输出 |
| **主机名** | `sys` 输出 |
| **宕机时间** | `sys` 输出 |
| **宕机类型** | `log \| tail -100` 判断 |
| **RIP / RSP / RBP** | `p /x $rip` 等 |
| **panic_processor 编号** | `help -t \| awk ...` |
| **处理器型号** | 第一步 B |
| **物理核心编号** | 第一步 B |
| **BIOS 版本** | `sys -i \| grep DMI_BIOS_VERSION` |
| **微码版本** | 第一步 B |

### 3.4 宕机类型识别

从日志中判断宕机类型：

| 日志关键词 | 宕机类型 |
|-----------|---------|
| `kernel panic` | 内核严重错误 |
| `oops` / `BUG: unable to handle` | 内核非致命错误（含 NULL pointer dereference、general protection fault 等） |
| `MCE` / `machine check` | 硬件异常 |
| `soft lockup` | CPU 软死锁（长时间未响应） |
| `hard lockup` / `NMI watchdog` | CPU 硬死锁（中断被长时间屏蔽） |
| `hung task` / `task .* blocked` | 任务长时间阻塞 |
| `BUG:` / `kernel BUG` | 内核断言失败 |
| `stack-protector` / `stack corrupted` | 栈保护器检测到栈损坏 |

### 3.5 常见问题

- **crash 无法启动**（cannot open object file）：确认 vmlinux 和 vmcore 文件路径正确，使用通配符 `vmlinux*`
- **寄存器值为 0 或不合理**：通过 `bt` 获取寄存器值，或者通过内核日志获取
- **调用堆栈不完整**：尝试 `bt -f` 显示完整堆栈帧信息

---

## 4. 第二步：加载内核源码（可选）

### 4.1 定位源码

根据第一步收集的内核版本号和主机名前缀（取主机名第一个 `_` 之前的部分，如 `soc_1_2_3_4` 提取前缀 `soc`）定位对应源码。

详细版本对应规则见 [附录 B：定制内核源码与热补丁定位](#附录-b-定制内核源码与热补丁定位)。

### 4.2 加载状态说明

- 若未加载，在分析报告源码加载状态处注明原因（环境问题/权限问题/判断无需源码等），并说明"分析基于反汇编结果"
- 若因 SSH 权限问题无法访问仓库，提示用户添加 SSH 公钥并通过 `ssh -T git@git.example.com` 验证后重试
- **后续分析过程中若有需要（如需确认源码逻辑、验证补丁是否包含等），可随时主动加载源码**

---

## 5. 第三步：硬件异常检查

**执行顺序（必须严格遵守）**：

1. **立即执行** 硬件异常之日志异常检查
2. **立即执行** 硬件异常之 vmcore 异常检查
3. **根据宕机类型选择执行** 硬件异常之 vmcore 异常深入分析

### 5.1 日志异常检查（必须执行）

检查内核日志中是否存在 MCE 报错信息，以及 ipmitool sel 日志（如有 `sel_list.log`）中是否存在硬件故障信息。

**如存在 vmcore-dmesg.txt 文件**：
```bash
grep -i "MCE\|machine check\|hardware error" vmcore-dmesg.txt
```

**否则执行标准命令**：
```bash
crash -s --no_crashrc vmlinux* vmcore <<EOF
log | grep -i "MCE\|machine check\|hardware error"
quit
EOF
```

记录检查结果（有/无硬件错误日志）。

### 5.2 vmcore 异常检查（必须执行）

#### 5.2.1 步骤 1：RIP 对齐检查

```bash
crash -s --no_crashrc vmlinux* vmcore <<EOF
dis -r <RIP值>
quit
EOF
```

- `<RIP值>` 需替换为第一步收集的实际十六进制地址（如 `0xffffffff81234567`）
- 检查 RIP 地址是否出现在某条指令的**起始地址**列（行首地址字段）

| 情况 | 判定 |
|------|------|
| RIP 等于某行起始地址 | **对齐正常** |
| RIP 落在两条相邻指令起始地址之间（`前条起始 < RIP < 后条起始`） | **RIP 截断执行（对齐异常）→ 硬件异常** |

#### 5.2.2 步骤 2：汇编执行逻辑检查

**核心原则**：将宕机异常类型与 RIP 指向指令的操作数实际值做推演验证。若宕机原因在指令语义上无法成立（操作数值与异常触发条件矛盾），则说明该指令在处理器执行过程中发生了异常，判定为硬件异常。

**检查步骤**：
1. 从 `dis -r <RIP值>` 输出中确认 RIP 指向的具体汇编指令
2. 分析该指令语义，确定哪些寄存器/内存作为关键操作数
3. 读取关键操作数的实际值：
   ```bash
   crash -s --no_crashrc vmlinux* vmcore <<EOF
   p /x $<寄存器名>
   quit
   EOF
   ```
4. 对比操作数实际值与宕机异常类型的触发条件是否自洽

**常见指令检查要点**：

| 指令类型 | 关键操作数 | 异常类型 | 硬件异常判定条件 |
|----------|-----------|----------|------------------|
| `div` / `idiv` | 除数寄存器（如 `%r8d`、`%rcx`） | `#DE` 除零错误 | 除数寄存器值**非 0**，但触发了除零异常 |
| `mov` / `load` | 内存地址寄存器（如 `%rax`、`%rsi`） | `#PF` 页错误 | 地址值在内核合法范围内且页表项有效，但触发页错误 |
| `call` / `jmp` | 目标地址寄存器（如 `%rax`） | `#GP` 一般保护错误 | 目标地址在合法内核范围内，但触发了 GP 异常 |
| `ud2` / 非法操作码 | — | `#UD` 非法指令 | RIP 指向字节序列在正常代码段中不应出现 `ud2`，可能是内存位翻转导致指令损坏 |

**重要：逻辑自洽时不能仅凭 bit 翻转特征判定硬件异常**

当指令语义与异常类型逻辑自洽（即"操作数值本身就是异常值"），即使操作数看起来像单 bit 翻转（如 `0xbfff... = 0xffff... ^ 0x4000000000000000`），**也不能直接判定为硬件异常**。理由：
- 软件 UAF、内存越界写入等同样可以产生看起来像 bit 翻转的损坏值
- 硬件 bit 翻转会翻转内存中已存储的值，而 UAF 是将一个带有异常 bit 的指针值写入了不应写入的位置

**逻辑自洽时的处置规则（必须执行）**：

步骤 2 判定逻辑自洽后，**必须追溯关键寄存器的值的来源**，才能区分软件与硬件：

1. 找到该寄存器值在宕机前最后一次被写入的指令（通过反汇编调用路径确认）
2. 检查写入该值的内存位置（如 slab freelist 指针、链表指针等）是否属于正常内核数据结构
3. 使用 `kmem <地址>` 检查相关 slab 对象状态，关注：
   - `invalid freepointer` 报告 → slab 数据损坏，需进一步分析是软件写坏还是硬件翻转
   - 对象 `f_count = 0` + `fu_rcuhead.func = <某free函数>` → 对象已释放，损坏来自 UAF
4. 读取损坏地址所在内存页的 page 结构，检查 `mapping`、`lru` 等字段是否有 `dead000000000xxx` poison 值（表明对象生命周期异常）
5. **只有在排除软件路径（无 UAF、无越界写入证据）后，且损坏地址对应的物理内存页无其他异常写入来源时，才可判定为硬件 bit 翻转**

**判定流程（`#GP` / `#PF` 逻辑自洽后的分支）**：

```
寄存器值异常（触发 GP/PF）
    ↓
追溯该值从哪里被加载（反汇编确认源头内存地址）
    ↓
检查源头内存位置的所属数据结构
    ├── kmem 报告 invalid freepointer
    │       ↓
    │   检查对应 slab 对象状态
    │       ├── f_count=0 且 fu_rcuhead.func=free回调  →  UAF（软件问题），进入软件分析
    │       ├── page->mapping = dead000000000xxx       →  对象已释放/被重用，UAF 可能性高
    │       └── 无软件损坏证据，物理地址对应内存无异常写入  →  可能硬件 bit 翻转
    └── 无 slab 异常
            ↓
        检查是否为链表指针、引用计数等被越界写入
            ├── 发现越界/UAF 写入来源  →  软件问题，进入软件分析
            └── 无软件来源  →  可能硬件 bit 翻转
```

**示例 - 除零错误判定为硬件异常**：
```
# RIP 指向指令：
0xffffffff81234567 <some_func+42>:  div %r8d

# 读取除数寄存器实际值：
crash> p /x $r8
$1 = 0x5a3f1c   ← 非 0

# 宕机类型：#DE divide error
# 逻辑矛盾：除数 r8d = 0x5a3f1c 非零，不可能触发除零异常
# → 判定：除数 r8d 非零却触发除零异常，指令在处理器执行过程中发生了异常，属于硬件异常
```

**示例 - 除零错误逻辑自洽（不能判定硬件异常）**：
```
# RIP 指向指令：
0xffffffff81234567 <some_func+42>:  div %r8d

# 读取除数寄存器实际值：
crash> p /x $r8
$1 = 0x0   ← 值为 0

# 宕机类型：#DE divide error
# 逻辑自洽：除数 r8d = 0，与除零异常完全一致
# → 无法凭此判定硬件异常，需继续软件路径分析
```

**示例 - #GP 逻辑自洽但不能判定硬件（典型 UAF 案例）**：
```
# RIP 指向指令：
kmem_cache_alloc+136: mov 0x0(%r13,%rax,1),%rbx

# R13 = 0xbfff88823dabe008（非规范地址，bit 62 = 0）
# 宕机类型：#GP general protection fault
# 逻辑自洽：访问非规范地址触发 GP，完全符合

# 错误推断：0xbfff... = 0xffff... ^ 0x4000000000000000，单 bit 翻转 → 硬件
# 正确做法：追溯 R13 来源 → R13 从 cpu_slab->freelist 加载
#             → kmem -s filp 报告 invalid freepointer: bfff88823dabe008
#             → kmem 0xffff88823dabe008 → 对象 f_count=0, fu_rcuhead.func=file_free_rcu
#             → 对象处于 RCU 释放队列，其 f_tfile_llink 字段被 UAF 写为损坏值
#             → 结论：UAF 软件问题，进入软件路径分析
```

#### 5.2.3 步骤 3：Code Cache 异常检查

从内核日志中提取 Code 字节序列，与 vmcore 中 RIP 地址处的内容比对，并验证字节序列是否能被解析为正常指令：

```bash
# 1. 从内核日志提取 Code 字节序列
# 格式示例：Code: 48 8b 45 f0 <48> 89 c7 e8 ...（尖括号标记 RIP 指向字节）
crash -s --no_crashrc vmlinux* vmcore <<EOF
log | grep "^Code:"
quit
EOF

# 2. 从 vmcore 中读取 RIP 地址处字节序列，与日志 Code 比对
crash -s --no_crashrc vmlinux* vmcore <<EOF
rd -8 <RIP地址> <字节数>
quit
EOF

# 3. 反汇编 RIP 地址处指令，验证字节序列是否为正常指令
crash -s --no_crashrc vmlinux* vmcore <<EOF
dis -r <RIP地址>
quit
EOF
```

**比对逻辑**：
- **日志 Code = vmcore 且可正常反汇编**：Code Cache 无异常
- **日志 Code ≠ vmcore**：日志记录时与内存内容不一致，可能存在 Code Cache 异常，仅作异常提示
- **日志 Code = vmcore 但无法被解析为正常指令**（如出现 `ud2`、非法操作码）：可能存在内存位翻转，仅作异常提示

### 5.3 vmcore 异常深入分析（基于宕机类型选择性执行）

根据基本信息收集阶段已记录的宕机类型，直接选择对应定向分析流程。

#### 5.3.1 条件 1：invalid opcode / illegal instruction

**执行条件**：宕机日志包含 "invalid opcode" 或 "illegal instruction"

```bash
crash -s --no_crashrc vmlinux* vmcore <<EOF
log | grep -i "invalid opcode\|illegal instruction" -A 20
p /x $rip
dis $rip
quit
EOF
```

**分析要点**：
1. 检查 RIP 指向的汇编指令是否为有效指令
2. 验证处理器是否支持该指令的特定特性
3. 参考 Intel SDM / AMD PM 检查指令兼容性

#### 5.3.2 条件 2：page fault / general protection fault

**执行条件**：宕机日志包含 "page fault" 或 "general protection"

```bash
crash -s --no_crashrc vmlinux* vmcore <<EOF
log | grep -i "page fault\|general protection" -B 5 -A 20
p /x $rip
pte $(echo "unable to handle kernel paging request at" | awk '{print $NF}')
dis $rip
quit
EOF
```

**分析要点**：
1. 提取 fault address 并检查页表项
2. 分析 RIP 指令是否访问了无效内存地址
3. 验证内存访问地址与 fault address 是否一致

#### 5.3.3 条件 3：stack-protector / stack corrupted

**执行条件**：宕机日志包含 "stack-protector" 或 "stack corrupted"

```bash
crash -s --no_crashrc vmlinux* vmcore <<EOF
log | grep -i "stack-protector\|stack corrupted" -B 10 -A 10
task -R stack_canary
p /x $gs:0x28
bt -f
x /xg $rsp+8
quit
EOF
```

**分析要点**：

1. **三个位置的 canary 值对比分析**：
   - **当前进程的 canary 值**：从 `task_struct->stack_canary` 获取（通过 `task -R stack_canary`）
   - **percpu area 存储的 canary 值**：从 `%gs:0x28` 获取（通过 `p /x $gs:0x28`）
   - **堆栈上存储的 canary 值**：从堆栈帧中获取（通过 `x /xg $rsp+8` 或其他堆栈偏移）

2. **对比分析过程**：
   - **正常情况**：三个位置的 canary 值应该完全一致
   - **异常情况**：如果三个值不一致，说明堆栈可能被破坏
   - **异常提示**：如果 canary 值在合理的范围内随机变化，可能存在内存损坏，仅作异常提示，不作为硬件异常判定依据

3. **详细分析步骤**：
   - **步骤 1**：获取 `task_struct->stack_canary` 值（进程初始化时设置的 canary）
   - **步骤 2**：获取 `%gs:0x28` 的 canary 值（当前线程的 canary 副本）
   - **步骤 3**：从堆栈帧中提取保存的 canary 值（函数调用时保存的原始 canary）
   - **步骤 4**：对比三个值是否一致，如果不一致则分析差异模式
   - **步骤 5**：检查差异是否存在异常特征（如随机位翻转、特定模式损坏等），仅作异常提示，不作为硬件异常判定依据

4. **异常特征识别**（仅作提示，不作为硬件异常判定依据）：
   - **随机位翻转**：canary 值中出现随机位变化
   - **内存损坏模式**：canary 值被特定模式覆盖（如全 0、全 1 等）
   - **一致性破坏**：三个位置的值出现不一致但符合异常损坏模式

5. **堆栈偏移计算**：
   - **标准 x86_64 调用约定**：canary 通常保存在 `$rsp+8` 位置
   - **特殊情况**：根据具体函数调用和编译器优化，可能需要调整偏移量
   - **验证方法**：通过 `dis $rip` 查看函数序言代码确认 canary 保存位置

### 5.4 硬件异常检查结论

- **若判定为硬件异常** → 可直接终止分析，输出分析报告
- **若未判定为硬件异常** → 继续执行软件异常分析（第四步）

---

## 6. 第四步：软件异常检查

在硬件异常检查未判定为硬件异常时执行。每步执行后记录关键结果和推理过程。

> **重要原则**：分析锁相关问题时（spinlock、mutex、rwsem、completion 等），必须结合当前 vmcore 对应的内核源码查看具体实现，确认锁结构体字段含义、持有者记录方式等，**不得主观臆断锁的实现逻辑**。不同内核版本的锁实现可能存在显著差异。

### 6.1 通用分析流程

根据基本信息收集阶段已记录的宕机类型，直接选择对应分析路径：

| 宕机类型 | 分析路径 |
|---------|---------|
| oops | [6.2 oops 分析](#62-oops-分析) |
| panic | [6.3 panic 分析](#63-panic-分析) |
| soft lockup | [6.4 soft lockup 检查](#64-soft-lockup-检查) |
| hard lockup | [6.5 hard lockup 检查](#65-hard-lockup-检查) |
| hung task | [6.6 hung task 检查](#66-hung-task-检查) |
| 内存相关 | [6.7 内存相关异常分析](#67-内存相关异常分析) |
| 进程/调度问题 | [6.8 进程和调度异常分析](#68-进程和调度异常分析) |

完成对应类型分析后，执行 [6.9 Linux Upstream 社区问题检查](#69-linux-upstream-社区问题检查)。

### 6.2 oops 分析

1. 提取错误地址和调用栈
2. 反汇编错误地址，分析错误位置代码
3. 检查空指针解引用、内存越界等常见错误
4. 分析相关变量值是否合理

```bash
crash -s --no_crashrc vmlinux* vmcore <<EOF
log | grep -i "oops" -A 20
bt
dis <error_address>
rd <variable_address>
quit
EOF
```

#### sysrq 触发 crash 的特殊处理

若日志中出现以下特征，说明宕机由 sysrq 手动触发，**而非真实故障直接引发**：

```
SysRq : Trigger a crash
BUG: unable to handle kernel NULL pointer dereference at (null)
IP: [<...>] sysrq_handle_crash+0x16/0x20
```

此时 `sysrq_handle_crash` 本身只是"收尸"操作，**真正的根因可能在更早的日志中**。**无论是否发现先发异常，必须进行宕机原因回溯，且回溯检查结果必须包含在报告中**。

```bash
crash -s --no_crashrc vmlinux* vmcore <<EOF
# 检查是否有 soft/hard lockup
log | grep -i "soft lockup\|hard lockup\|nmi watchdog"
# 检查是否有 hung task
log | grep -i "hung_task\|hung task\|task .* blocked"
# 检查是否有其他 oops/panic（在 sysrq 之前）
log | grep -i "oops\|BUG:\|kernel BUG\|general protection"
# 查看完整日志确认时序
log | tail -200
quit
EOF
```

根据回溯结果：
- 若发现 **soft/hard lockup**：转至 soft/hard lockup 检查流程
- 若发现 **hung task**：转至 hung task 检查流程；若未发现但需排查，需检查 `sysctl_hung_task_warnings` 变量
- 若发现**其他 oops/BUG**：以该 oops 作为真正根因进行分析
- 若日志中**未发现其他异常**：检查是否存在内存泄露，通过 `kmem -i` 确认是否存在异常偏高的内存项
  ```bash
  crash -s --no_crashrc vmlinux* vmcore <<EOF
  # 查看整体内存使用（重点关注 SReclaimable 和 SUnreclaim）
  kmem -i
  # 查看各 slab cache 占用，按 TOTAL 排序找异常增长的 cache
  kmem -s
  # 获取 NR_SLAB_RECLAIMABLE 和 NR_SLAB_UNRECLAIMABLE 页面数用于验证统计一致性
  kmem -V
  quit
  EOF
  ```
  > **注意**：从内核 **5.4 版本**开始，`kmalloc` 申请**大于 8KB** 的内存会统计到 `SUnreclaim` 中，如果 SLAB 占用较高，需要通过 `kmem -V` 获取 `NR_SLAB_RECLAIMABLE` 和 `NR_SLAB_UNRECLAIMABLE` 的页面数，并计算出**大于 8KB** 内存的占用量，从而排除大块 kmalloc 的正常占用，判断是否存在真正的 slab 泄露
- 若日志中**仅有 sysrq crash，无其他异常**且 `sysctl_hung_task_warnings == 10`：说明是人为主动触发，非系统故障，报告中注明即可

### 6.3 panic 分析

1. 查看 panic 错误描述和触发条件
2. 分析 panic 调用栈，确定触发路径
3. 检查相关内核数据结构状态
4. 分析资源耗尽、死锁、竞态条件等原因

```bash
crash -s --no_crashrc vmlinux* vmcore <<EOF
log | grep -i "panic" -A 20
bt
ps | grep -i "UN\|RU"
kmem -i
quit
EOF
```

**常见 panic 类型**：
- **资源耗尽**：检查内存、文件描述符、进程数限制
- **死锁**：检查进程状态和锁持有情况
- **内核 BUG**：检查是否触发 BUG_ON 条件
- **竞态条件**：分析并发访问和同步机制

### 6.4 soft lockup 检查

1. 检查 watchdog 超时原因
2. 如果是 smp_call_function_* 导致的死锁，检查所有处理器是否存在 pending IPI
3. 分析 CPU 调度状态和进程阻塞情况

```bash
crash -s --no_crashrc vmlinux* vmcore <<EOF
log | grep -i "soft lockup" -A 20
bt
ps
foreach bt
quit
EOF
```

### 6.5 hard lockup 检查

1. 检查 NMI watchdog 触发原因
2. 分析中断处理状态和中断屏蔽情况
3. 检查是否有处理器长时间关中断

```bash
crash -s --no_crashrc vmlinux* vmcore <<EOF
log | grep -i "hard lockup\|nmi watchdog" -A 20
bt
sys | grep -i "irq"
quit
EOF
```

### 6.6 hung task 检查

1. 从日志提取被阻塞进程名、PID 和阻塞时长
2. 检查所有 D 状态进程，分析调用栈判断阻塞根因
3. 追溯链式阻塞，找到最初阻塞原因

```bash
crash -s --no_crashrc vmlinux* vmcore <<EOF
log | grep -i "hung_task\|INFO: task.*blocked" -A 30
ps | grep " UN "
foreach bt
quit
EOF
```

> **注意**：若日志中未发现 hung task 告警，需检查内核变量 `sysctl_hung_task_warnings`：
> ```bash
> crash -s --no_crashrc vmlinux* vmcore <<EOF
> p sysctl_hung_task_warnings
> quit
> EOF
> ```
> 若 `sysctl_hung_task_warnings != 10`，说明内核可能已消耗告警次数，此情况下不能因无日志而排除 hung task 问题，仍需通过 `ps | grep " UN "` 检查 D 状态进程。

### 6.7 内存相关异常分析

1. 检查 slab 分配器状态（`kmem -s`），识别分配异常
2. 分析内存使用情况，检查内存泄漏和碎片化
3. 检查页表映射是否正确，验证内存访问权限

```bash
crash -s --no_crashrc vmlinux* vmcore <<EOF
kmem -s
kmem -i
vm -m
quit
EOF
```

**页表检查**：
```bash
crash -s --no_crashrc vmlinux* vmcore <<EOF
pte <address>
vtop <virtual_address>
quit
EOF
```

**常见内存问题**：内存泄漏、内存碎片、页表错误、权限错误、缓存污染

### 6.8 进程和调度异常分析

1. 检查所有进程状态，识别异常进程
2. 分析进程资源使用情况（内存、文件描述符、CPU 时间等）
3. 检查进程间关系和通信状态
4. 验证调度器状态

```bash
crash -s --no_crashrc vmlinux* vmcore <<EOF
ps
task <pid>
files <pid>
vm <pid>
quit
EOF
```

**调度器状态**：
```bash
crash -s --no_crashrc vmlinux* vmcore <<EOF
runq
foreach ps
sys | grep -i "sched"
quit
EOF
```

**常见进程问题**：进程死锁、调度异常、资源耗尽、信号处理异常、IPC 状态异常

### 6.9 Linux Upstream 社区问题检查

在完成初步软件异常分析后，检查 Linux upstream 社区是否已存在相同或相似的问题报告、补丁或讨论。

#### 6.9.1 检查目标

根据已分析的宕机信息，提取以下关键要素用于社区检索：
- 调用栈中的核心函数名（如 `do_page_fault`、`__alloc_pages_nodemask`）
- panic/oops 的错误描述字符串（如 `"BUG: unable to handle kernel NULL pointer dereference"`）
- 涉及的内核子系统（如 mm、net、fs、scheduler）
- vmcore 的内核版本

#### 6.9.2 检索渠道

**1. 本地 upstream 源码（优先）**

优先通过本地 upstream 源码缓存检索：

```bash
KERNEL_PATH="<本地 linux 仓库路径>"

# 通过 git log 检索相关修复提交
git -C $KERNEL_PATH log --oneline --all --grep="<函数名>" | head -20
git -C $KERNEL_PATH log --oneline --all --grep="<错误关键词>" | head -20

# 找到 commit 后，查看首次包含该 commit 的 tag
git -C $KERNEL_PATH tag --contains <commit_id> | sort -V | head -5
```

**2. kernel.org Git 提交记录（本地缓存不存在时）**

```
搜索地址: https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/log/
示例 URL: https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/log/?qt=grep&q=<关键词>
```

**3. Linux Kernel Mailing List (LKML)**

```
搜索地址: https://lore.kernel.org/all/?q=<关键词>

检索内容:
- 相同 panic 信息的 bug 报告
- 相关函数的修复补丁讨论
- 已知 regression 的报告
```

**4. kernel.org Bugzilla**

```
搜索地址: https://bugzilla.kernel.org/query.cgi
检索字段: Summary 或 Description 包含调用栈函数名或错误描述
```

#### 6.9.3 检索关键词构造方法

从 crash 分析结果中提取关键词：

```bash
# 提取调用栈中的核心函数（排除通用函数如 schedule、ret_from_fork）
crash -s --no_crashrc vmlinux* vmcore <<EOF
bt
log | grep -E "BUG:|Oops:|Call Trace:" -A 30
quit
EOF
```

**关键词优先级（由高到低）**：
1. panic 错误字符串中的具体描述（如 `"list_del corruption"`）
2. RIP 指向的函数名（崩溃发生的直接位置）
3. 调用栈中业务相关的函数名（排除通用路径函数）
4. 涉及的数据结构名称

#### 6.9.4 链接格式要求

**Commit 链接格式**：所有报告中提及的 commit 信息必须提供可点击的链接，格式为 `[Commit <哈希>](<完整链接>)`，例如：
- `[Commit d38e9f04ebf667d9cb8185b45bff747485f1d3e9](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=d38e9f04ebf667d9cb8185b45bff747485f1d3e9)` (nvme-pci: Support shared tags across queues for Apple 2018 controllers)

**CVE 链接格式**：所有报告中提及的 CVE 漏洞必须提供可点击的链接，格式为 `[CVE-编号](<完整链接>)`，例如：
- `[CVE-2025-38349](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2025-38349)`：Linux kernel eventpoll use-after-free 漏洞

**LKML 链接格式**：所有报告中提及的 LKML 讨论必须提供可点击的链接，格式为 `[LKML 主题](<完整链接>)`，例如：
- `[LKML: "Memory management issue in mmap region"](https://lore.kernel.org/lkml/20250415123045.12345678@example.com/)`：关于 mmap 区域内存管理问题的讨论

#### 6.9.5 分析结论记录

检索后记录以下信息：
- **已知问题**：找到相同问题的 bug 报告或补丁，记录 commit ID、链接、首次包含该修复的上游 tag（最早修复版本）及下游修复版本
- **相关补丁**：找到功能相关的修复补丁，评估是否与当前问题相关，记录 commit ID、链接及首次包含该修复的上游 tag
- **未见报告**：社区未见相同问题，可能为新 bug 或环境特定问题
- **已修复未合入**：upstream 已有修复但 vmcore 内核版本未包含，需记录 commit ID、链接及首次包含该修复的上游 tag，建议 backport commit 或升级内核至包含该修复的版本；若已加载内核源码，须确认：（1）对应源码中是否存在相同问题，（2）是否已以其他形式（如热补丁、私有 backport）包含该修复；若尚未加载源码，此时应主动加载后再确认

---

## 7. 第五步：子系统定向检查

根据异常类型选择性执行。

### 7.1 网络栈异常检查

**执行条件**：
- 宕机日志包含网络相关错误时执行
- 宕机类型为网络驱动异常时执行
- 其他情况下根据实际需要选择性执行

#### 网络设备状态检查
```bash
crash -s --no_crashrc vmlinux* vmcore <<EOF
dev
net
quit
EOF
```

#### Socket 状态分析
```bash
crash -s --no_crashrc vmlinux* vmcore <<EOF
files | grep socket
net -s
quit
EOF
```

#### 网络协议栈分析
```bash
crash -s --no_crashrc vmlinux* vmcore <<EOF
net -a
struct sk_buff <address>
quit
EOF
```

**常见网络问题**：网络设备驱动异常、协议栈死锁、Socket 泄漏、网络缓冲区问题

### 7.2 存储栈异常检查

**执行条件**：
- 宕机日志包含存储相关错误时执行
- 宕机类型为存储驱动异常时执行
- 宕机日志包含 I/O 超时或错误时执行
- 其他情况下根据实际需要选择性执行

#### 块设备状态检查
```bash
crash -s --no_crashrc vmlinux* vmcore <<EOF
dev | grep -i "block\|scsi\|ata\|nvme"
quit
EOF
```

#### I/O 请求队列分析
```bash
crash -s --no_crashrc vmlinux* vmcore <<EOF
dev -d
struct request_queue <address>
quit
EOF
```

#### 文件系统状态检查
```bash
crash -s --no_crashrc vmlinux* vmcore <<EOF
files
mount
struct super_block <address>
quit
EOF
```

**常见存储问题**：块设备驱动异常、I/O 队列堵塞、文件系统损坏、SCSI/NVMe 错误、磁盘超时

---

## 8. 第六步：输出分析报告

> 分析报告必须使用中文输出。

### 8.1 宕机总结关键字（必须包含，50 字以内）

**系统异常宕机**格式：`关键 RIP（符号+偏移量） + 原因`

**示例**：
```
_raw_spin_lock_irqsave+0x14 空指针解引用
nvme_setup_io_queues+0x1a 竞态条件导致内存访问越界
```

**人为触发宕机**格式：`原因 + 现象`

**示例**：
```
人为 sysrq 触发，日志无其他异常
人为 sysrq 触发，SUnreclaim 占用 120GB 持续增长
```

### 8.2 一句话结论（必须包含，300 字内）

格式：`宕机原因说明 + 硬件异常内容说明（如有）+ 修复建议描述 + 处理器型号:<值> + 逻辑核心:<编号>（物理核心:<编号>）+ BIOS 版本:<值> + 微码版本:<值> + 内核版本:<值>`

**软件异常示例**：
```
系统因空指针解引用导致内核 oops 并触发 panic，建议添加空指针检查并更新内核版本，处理器型号：Intel(R) Xeon(R) Gold 6248R CPU，逻辑核心:2（物理核心:1），BIOS 版本:2.8.0，微码版本:0x5003604，内核版本:5.10.0-123.el8.x86_64
```

**硬件异常示例（MCE）**：
```
系统因硬件异常导致宕机，内核日志检测到 MCE（Machine Check Exception）错误：Bank 1 报告 DRAM 内存 ECC 不可纠正错误（MCACOD=0x0080，MSCOD=0x0010），物理地址 0x1a2b3c4d5e6f，建议检查并更换故障内存条，处理器型号：Intel(R) Xeon(R) Gold 6248R CPU，逻辑核心:2（物理核心:1），BIOS 版本:2.8.0，微码版本:0x5003604，内核版本:5.10.0-123.el8.x86_64
```

**硬件异常示例（RIP 截断）**：
```
系统因硬件异常导致宕机，检测到 RIP 寄存器截断执行：RIP 值 0xffffffff81234567 未与函数内指令地址严格对齐，疑似指令指针被硬件异常篡改，建议检查 CPU 及内存硬件状态，处理器型号：Intel(R) Xeon(R) Gold 6248R CPU，逻辑核心:2（物理核心:1），BIOS 版本:2.8.0，微码版本:0x5003604，内核版本:5.10.0-123.el8.x86_64
```

### 8.3 基本信息（必须包含）

| 字段 | 值 |
|------|----|
| **主机名** | prod-db-01.example.com |
| **宕机时间** | 2025-01-15 14:23:45 CST |
| **宕机类型** | kernel oops (NULL pointer dereference) |
| **内核版本** | 5.10.0-123.el8.x86_64 |
| **处理器型号** | Intel(R) Xeon(R) Gold 6248R CPU @ 3.00GHz |
| **处理器编号** | 逻辑核心 2（物理核心 1） |
| **BIOS 版本** | 2.8.0 |
| **微码版本** | 0x5003604 |

### 8.4 详细分析结构

1. **源码加载状态**: 已加载定制内核源码（tag: 3.10.0-123_456） / 未加载（原因：<环境访问问题/SSH 权限未配置/判断当前分析无需源码（如纯硬件异常）等>，分析基于反汇编结果）
2. **宕机类型**: kernel oops (NULL pointer dereference)
3. **根本原因**: 软件错误 / 硬件异常
4. **触发条件**: 在 some_module 模块的 some_function 函数中访问了空指针
5. **证据和推理**:
   - **宕机内核日志 Call Trace**（必须包含，触发宕机前几行日志至结束的完整日志）
   - 内核日志显示: "BUG: unable to handle kernel NULL pointer dereference at 0000000000000008"
   - 调用栈显示错误发生在 some_function+0x12/0x34
   - 反汇编代码显示该位置试图从 %rax+0x8 读取数据，而 %rax 为 NULL
   - 追溯调用链发现上层函数未正确初始化该指针
6. **上游社区检查**（软件异常必须包含，纯硬件异常可省略）:
   - 在 lore.kernel.org 以 `some_function null pointer` 为关键词检索，发现 [Commit afb16d3e8e031b25993df65dfdb92e503f596916](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=afb16d3e8e031b25993df65dfdb92e503f596916) 修复了类似问题
   - 发现相关漏洞：[CVE-2024-12345](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2024-12345)：Linux kernel some_function null pointer dereference 漏洞
   - 相关讨论：[LKML: "null pointer issue in some_function"](https://lore.kernel.org/lkml/20250415123045.12345678@example.com/)
   - 首次包含该修复的上游 tag：v5.15-rc3
   - vmcore 内核版本 5.10.0-123 未包含该修复，属于已知 bug
   - 已加载内核源码：确认定制内核 tag 3.10.0-123_456 源码中存在相同问题，未包含该修复补丁，亦未发现对应热补丁
   - 建议 backport [Commit afb16d3e8e031b25993df65dfdb92e503f596916](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=afb16d3e8e031b25993df65dfdb92e503f596916) 或升级内核至 v5.15-rc3 及以上版本
7. **修复建议**:
   - 在 some_function 中添加空指针检查
   - 修复上层调用函数的指针初始化逻辑
   - 更新到已修复此问题的内核版本或应用补丁
8. **预防措施**:
   - 启用内核调试选项以更早发现此类问题
   - 加强代码审查，确保指针使用前进行有效性检查
   - 定期更新内核版本以获取最新的修复

---

## 9. 快速参考：常见场景分析示例

### 示例 1：基础信息收集

完整命令和说明参考 [第三步](#3-第一步基础信息收集)。

### 示例 2：硬件异常之日志异常检查

**如存在 vmcore-dmesg.txt 文件**：
```bash
grep -i "MCE\|machine check\|hardware error" vmcore-dmesg.txt
```

**否则执行标准命令**：
```bash
crash -s --no_crashrc vmlinux* vmcore <<EOF
log | grep -i "MCE\|machine check\|hardware error"
quit
EOF
```

### 示例 3：硬件异常之 vmcore 异常检查

```bash
crash -s --no_crashrc vmlinux* vmcore <<EOF
dis -r <RIP值>
p /x $rip
p /x $rsp
p /x $rbp
log | grep "^Code:"
rd -8 <RIP地址> <字节数>
quit
EOF
```

### 示例 4：panic 分析

```bash
crash -s --no_crashrc vmlinux* vmcore <<EOF
log | grep -i "panic" -A 30
bt
ps | head -20
kmem -i
quit
EOF
```

### 示例 5：soft lockup 分析

```bash
crash -s --no_crashrc vmlinux* vmcore <<EOF
log | grep -i "soft lockup" -A 30
bt
ps
foreach bt
quit
EOF
```

### 示例 6：sysrq 触发 crash 的回溯分析

```bash
crash -s --no_crashrc vmlinux* vmcore <<EOF
# 检查是否有 soft/hard lockup
log | grep -i "soft lockup\|hard lockup\|nmi watchdog"
# 检查是否有 hung task
log | grep -i "hung_task\|hung task\|task .* blocked"
# 检查是否有其他 oops/panic（在 sysrq 之前）
log | grep -i "oops\|BUG:\|kernel BUG\|general protection"
# 查看完整日志确认时序
log | tail -200
quit
EOF
```

根据回溯结果选择后续分析路径（参考 [6.2 oops 分析](#62-oops-分析) 中 sysrq 特殊处理章节）。

### 示例 7：hung task 分析

```bash
crash -s --no_crashrc vmlinux* vmcore <<EOF
# 提取 hung task 告警，获取被阻塞进程名、PID 和阻塞时长
log | grep -i "hung_task\|INFO: task.*blocked" -A 30
# 列出所有 D 状态进程
ps | grep " UN "
# 批量查看所有进程调用栈，理清阻塞链
foreach bt
quit
EOF
```

**分析要点**：
1. 从日志或 D 状态进程中确认被阻塞进程名和 PID
2. 对每个 D 状态进程 `bt <pid>`，根据调用栈判断阻塞类型：
   - `io_schedule` / `blk_mq_get_tag`：阻塞在 I/O，参考 [7.2 存储栈异常检查](#72-存储栈异常检查)
   - `mutex_lock` / `down_write` / `rwsem_down_*`：等待锁，需找到锁持有者
   - `sk_wait_data` / `rpc_wait_bit_killable`：网络/NFS 阻塞，参考 [7.1 网络栈异常检查](#71-网络栈异常检查)
3. 追溯链式阻塞：从等待者找持有者，再检查持有者是否也在等待，直至找到链头
4. **注意**：分析锁结构时必须结合当前内核源码确认字段含义，不得主观臆断

### 示例 8：空指针解引用

```bash
crash -s --no_crashrc vmlinux* vmcore <<EOF
log | grep -i "NULL pointer\|dereference" -A 20
bt
dis <fault_address>
rd <variable_address>
quit
EOF
```

### 示例 9：内存问题排查

```bash
crash -s --no_crashrc vmlinux* vmcore <<EOF
kmem -i
kmem -s | head -20
vm -m
bt
quit
EOF
```

### 示例 10：mwait_idle 宕机完整分析（硬件异常 - RIP 截断执行）

**场景**：宿主机宕机，RIP 指向 `mwait_idle` 函数，需要判断是硬件异常还是软件问题。

#### 第一步：基础信息收集

```bash
crash -s --no_crashrc vmlinux* vmcore <<EOF
sys
p /x $rip
p /x $rsp
p /x $rbp
bt
log | tail -100
help -t | awk -F: '/panic_processor/{print $2}'
sys -i | grep DMI_BIOS_VERSION
quit
EOF
```

**关键输出**：
- RIP = `0xffffffff81b69136`
- 宕机类型：（从 log 中确认）
- panic_processor：（记录编号，供下一步使用）

#### 第二步：收集处理器详细信息

```bash
crash -s --no_crashrc vmlinux* vmcore <<EOF
p cpu_info:<panic_processor> | sed -n 's/x86_model_id =/  x86_model_id:/p' | sed -e 's/\000//g' -e 's/\s*",$//'
pd cpu_info:<panic_processor> | sed -n "s/.*\(phys_proc_id\) = \(.*\),/\2/p"
px cpu_info:<panic_processor> | grep microcode
quit
EOF
```

#### 第三步：加载内核源码（可选）

根据内核版本号和主机名前缀定位对应源码。若无法加载，在报告中注明原因。

#### 第四步：日志异常检查

```bash
crash -s --no_crashrc vmlinux* vmcore <<EOF
log | grep -i "MCE\|machine check\|hardware error"
quit
EOF
```

#### 第五步：vmcore 异常检查

**步骤 1 - RIP 对齐检查**：

```bash
crash -s --no_crashrc vmlinux* vmcore <<EOF
dis -r 0xffffffff81b69136
quit
EOF
```

**真实输出（节选）**：
```
0xffffffff81b6912f <mwait_idle+159>: mov %gs:0x7e4a7489(%rip),%r12d
0xffffffff81b69137 <mwait_idle+167>: test %eax,%eax
```

**RIP 对齐判断**：
- RIP = `0xffffffff81b69136`
- 前条指令起始：`0xffffffff81b6912f`（mwait_idle+159）
- 后条指令起始：`0xffffffff81b69137`（mwait_idle+167）
- 验证：`0xffffffff81b6912f < 0xffffffff81b69136 < 0xffffffff81b69137`
- **结论：RIP 落在 `mwait_idle+159` 指令内部（该指令占 8 字节，范围 `0x6912f~0x69136`），非任何指令起始地址，判定为 RIP 截断执行**

**步骤 2 - 汇编执行逻辑检查**：

RIP 已判定为截断执行，寄存器值被硬件异常篡改，该步骤可跳过，直接输出硬件异常报告。

#### 最终报告示例

**宕机总结关键字**：
```
mwait_idle+0x7 RIP 截断执行（硬件异常）
```

**一句话结论**：
```
系统因硬件异常导致宕机，检测到 RIP 寄存器截断执行：RIP 值 0xffffffff81b69136 落在
mwait_idle+159 指令内部（指令字节范围 0xffffffff81b6912f~0xffffffff81b69136），
未对齐至任何指令起始地址，疑似指令指针被硬件异常篡改，建议检查 CPU 及内存硬件状态，
处理器型号：Intel(R) Xeon(R) Gold 6248R CPU，逻辑核心:<编号>（物理核心:<编号>），BIOS 版本:<值>，
微码版本:<值>，内核版本:5.4.32-1_00162.el8.x86_64
```

**基本信息**：

| 字段 | 值 |
|------|----|
| **主机名** | srv-192.168.1.100 |
| **宕机时间** | 2026-02-16 22:29:07 CST |
| **宕机类型** | kernel panic (硬件异常 - RIP 截断执行) |
| **内核版本** | 5.4.32-1_00162.el8.x86_64 |
| **处理器型号** | Intel(R) Xeon(R) Gold 6248R CPU |
| **处理器编号** | 逻辑核心 <编号>（物理核心 <编号>） |
| **BIOS 版本** | <值> |
| **微码版本** | <值> |

**证据和推理**：

**宕机内核日志 Call Trace**：
```
[12345678.901234] kernel log example line [2026-04-23 10:00:00]
...
[触发宕机前几行日志至结束的完整内核日志]
...
Call Trace:
 mwait_idle+0x?/0x?
 do_idle+0x?/0x?
 cpu_startup_entry+0x?/0x?
 ...
```

**证据链**：
1. `dis -r 0xffffffff81b69136` 输出显示相邻两条指令起始地址为 `0x6912f` 和 `0x69137`，RIP `0x69136` 夹在两者之间
2. `mwait_idle+159` 处的 `mov %gs:0x7e4a7489(%rip),%r12d` 指令长度为 8 字节（`0x69137 - 0x6912f = 8`），RIP 指向该指令最后一个字节
3. 正常执行流中 RIP 不可能指向指令中间，属于典型的硬件异常篡改特征

---

## 10. 调试技巧速查

### 10.1 反汇编分析

```bash
crash -s --no_crashrc vmlinux* vmcore <<EOF
dis <function_name>
dis -l <address>
sym <symbol_name>
quit
EOF
```

### 10.2 查看数据结构

```bash
crash -s --no_crashrc vmlinux* vmcore <<EOF
struct <struct_name> <address>
list <list_head_address>
tree <rb_tree_address>
quit
EOF
```

### 10.3 常用调试命令组合

| 目的 | 命令组合 |
|------|---------|
| 查看进程完整信息 | `ps` → `task <pid>` → `files <pid>` → `vm <pid>` |
| 分析内存问题 | `kmem -i` → `kmem -s` → `kmem -V` → `vm -m` |
| 分析调度问题 | `runq` → `foreach ps` → `bt <pid>` |
| 分析网络问题 | `dev` → `net` → `net -s` → `files \| grep socket` |
| 分析存储问题 | `dev \| grep block` → `dev -d` → `mount` → `files` |
| 分析页表 | `pte <addr>` → `vtop <vaddr>` |

---

## 附录 A：x86_64 内核内存布局

### 4 级页表虚拟内存映射

| Start addr | Offset | End addr | Size | VM area description |
|-----------|--------|---------|------|---------------------|
| 0000000000000000 | 0 | 00007fffffffefff | ~128 TB | user-space virtual memory |
| 00007ffffffff000 | ~128 TB | 00007fffffffffff | 4 kB | guard hole |
| 0000800000000000 | +128 TB | 7fffffffffffffff | ~8 EB | non-canonical hole |
| 8000000000000000 | -8 EB | ffff7fffffffffff | ~8 EB | non-canonical hole |
| ffff800000000000 | -128 TB | ffff87ffffffffff | 8 TB | guard hole (hypervisor) |
| ffff880000000000 | -120 TB | ffff887fffffffff | 0.5 TB | LDT remap for PTI |
| **ffff888000000000** | **-119.5 TB** | **ffffc87fffffffff** | **64 TB** | **direct mapping of all physical memory (page_offset_base)** |
| ffffc90000000000 | -55 TB | ffffe8ffffffffff | 32 TB | vmalloc/ioremap space |
| ffffea0000000000 | -22 TB | ffffeaffffffffff | 1 TB | virtual memory map (vmemmap_base) |
| ffffec0000000000 | -20 TB | fffffbffffffffff | 16 TB | KASAN shadow memory |
| fffffe0000000000 | -2 TB | fffffe7fffffffff | 0.5 TB | cpu_entry_area mapping |
| ffffff0000000000 | -1 TB | ffffff7fffffffff | 0.5 TB | %esp fixup stacks |
| **ffffffff80000000** | **-2 GB** | **ffffffff9fffffff** | **512 MB** | **kernel text mapping** |
| ffffffffa0000000 | -1536 MB | fffffffffeffffff | 1520 MB | module mapping space |
| ffffffffff600000 | -10 MB | ffffffffff600fff | 4 kB | legacy vsyscall ABI |

> **关键地址范围**：
> - 内核直接映射区：`ffff888000000000` 起（64 TB）
> - 内核代码段：`ffffffff80000000` 起（512 MB）
> - vmalloc 区：`ffffc90000000000` 起（32 TB）

---

## 附录 B：定制内核源码与热补丁定位

### B.1 定制内核版本识别

不同组织/厂商可能基于 Linux 上游内核进行定制，形成自己的内核版本体系。以下仅为示例格式，实际分析时应根据目标环境的内核版本特征进行识别：

| 内核版本特征示例 | 定制版本代号示例 |
|-----------|---------|
| `2.6.32-358.PLATFORM_1.<N>` | 定制版 A |
| `3.10.0-<N>.custom` | 定制版 B |
| `5.4.32-1_<N>.build` | 定制版 C |

### B.2 本地源码缓存管理

**使用前**，先从全局记忆中查找本地缓存路径：

- 若记忆中**已有缓存路径**，先执行 `git pull` 更新到最新，再使用：
  ```bash
  git -C <仓库路径> pull
  ```

- 若记忆中**无对应仓库路径**，按下方各版本章节中的默认路径克隆。克隆前先检查目录是否可写，若无权限则停止并提示用户手动克隆并告知路径：
  ```bash
  mkdir -p /data/sources/custom_kernel 2>/dev/null || {
      echo "无法创建目录，请手动克隆仓库并告知路径"
      exit 1
  }
  ```

若克隆时出现 SSH 权限错误（如 `Permission denied (publickey)`），提示用户：
1. 确认已将本机 SSH 公钥添加至代码托管平台（如 git.example.com）
2. 可通过 `ssh -T git@git.example.com` 验证连接是否正常
3. 检查 `git config --global --list` 是否有 `insteadof` 规则（可能导致 URL 重写），如有则删除相关配置后再重试
4. 若无仓库访问权限，联系仓库管理员申请权限
5. 权限问题解决后重新克隆

克隆完成后，**立即将实际路径保存到全局记忆（非项目级）中**，后续任意项目可直接读取使用。

### B.3 宕机分析：定位源码

**步骤**：

1. 根据内核版本号识别定制内核版本，进入对应章节
2. 更新本地仓库（`git pull`），将内核版本号转换为 tag，`git checkout` 到对应源码
3. 从堆栈中提取函数名，查看对应源文件和行号
4. 确认该函数是否被热补丁修改过（在热补丁仓库中搜索 patch 文件）
5. 若被热补丁修改，确认该版本是否已加载对应热补丁 ko

**示例**（定制版 B，内核版本 `3.10.0-123_456.custom`，主机名 `host_1_2_3_4`）：

```
Crash 堆栈：
#0  do_page_fault at arch/x86/mm/fault.c:1234
#1  handle_mm_fault at mm/memory.c:5678

操作：
1. 版本格式 3.10.0-<N>.custom → 定制版 B
2. 主机名前缀：host_1_2_3_4 → 提取前缀 host
3. tag = 3.10.0-123_456，git checkout 3.10.0-123_456
4. 查看 arch/x86/mm/fault.c 第 1234 行
5. grep -rl "do_page_fault" <hotfix_path>/patch/*.patch
6. 确认 ko：ls <hotfix_path>/utils/hotfix/<patch_name>/3.10.0-123_456/*.ko
```

### B.4 Linux 上游社区源码

**用途**：检索 Linux 上游内核源码，适用于查看通用内核实现、对比定制化修改等场景。

| 仓库 | 用途 | 地址 |
|------|------|------|
| `linux` | 上游内核源码（stable） | `git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git` |

本地路径从记忆中读取，默认缓存路径：

```bash
# 注意：仓库较大，首次克隆耗时较长
git clone git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git /data/sources/upstream/linux
```

**内核版本与 Tag 对应规则**：

上游 stable 仓库 tag 格式为 `v<major>.<minor>.<patch>`，如 `v5.4.32`。

```bash
# 提取 tag（kver 由用户提供，如 5.4.32）
KERNEL_PATH="<从记忆中读取 linux 路径>"
git -C $KERNEL_PATH checkout v${kver}
```

### B.5 定制版 A 详细配置（示例）

**识别特征**：内核版本号格式为 `2.6.32-358.PLATFORM_1.<N>`

| 仓库 | 用途 | 地址 |
|------|------|------|
| `custom_kernel_a` | 内核源码 | `git@git.example.com:AcmeCorp/Kernel/custom_kernel_a.git` |
| `custom_hotfixes_a` | 热补丁 | `git@git.example.com:AcmeCorp/Kernel/custom_hotfixes_a.git` |

**内核版本与 Tag 对应规则**：

格式：`2.6.32-358.PLATFORM_1.<N>` → tag `1.<N>`

| 内核版本示例 | Tag |
|---------|-----|
| `2.6.32-358.PLATFORM_1.34` | `1.34` |

```bash
# kver 从 vmcore sys 输出获取，以下为提取逻辑示意
tag=$(echo "$kver" | grep -oP 'PLATFORM_1\.\K[\d.]+')

# checkout 到对应版本
cd custom_kernel_a && git checkout $tag
```

**热补丁机制说明**：

定制版 A 使用自行实现的热补丁机制（非 kpatch），每个补丁为独立目录，包含 `.c` 源文件和 `Makefile`，编译生成 `.ko` 后加载。

仓库结构：
```
custom_hotfixes_a/hotfixes_src/
└── <patch_name>/          - 每个补丁一个目录
    ├── <patch_name>.c     - 补丁源码
    ├── Makefile           - 编译配置
    └── Makefile-<kver>    - 特定内核版本的编译配置
```

**热补丁检索**：

```bash
HOTFIX_PATH="<从记忆中读取>"

# 查找修改了特定函数的补丁（搜索 .c 源文件）
grep -rl "function_name" $HOTFIX_PATH/hotfixes_src/*/*.c
```

### B.6 定制版 B 详细配置（示例）

**识别特征**：内核版本号格式为 `3.10.0-<N>.custom`

| 仓库 | 用途 | 地址 |
|------|------|------|
| `custom_kernel_b` | 内核源码 | `git@git.example.com:AcmeCorp/Kernel/custom_kernel_b.git` |
| `custom_hotfix_b` | 热补丁 | `git@git.example.com:AcmeCorp/Kernel/custom_hotfix_b.git` |

**内核版本与 Tag 对应规则**：

格式：`3.10.0-<N>.custom` → tag `3.10.0-<N>`（去掉 `.custom` 后缀）

| 内核版本示例 | Tag |
|---------|-----|
| `3.10.0-123_456.custom` | `3.10.0-123_456` |

```bash
# kver 从 vmcore sys 输出获取，以下为提取逻辑示意
tag="${kver%.custom}"

# checkout 到对应版本
cd custom_kernel_b && git checkout $tag
```

**ko 文件路径规则**：

同一个补丁针对每个内核版本分别编译，不同部署场景可能有不同的 ko 路径：

| 场景 | ko 路径示例 |
|---------|--------|
| 场景一 | `utils/hotfix/<patch_name>/<kver>/kpatch-<name>.ko` |
| 场景二 | `utils/hotfix/<patch_name>/<kver>/kpatch.0.9.3/kpatch-<name>.ko` |

**热补丁检索**：

```bash
HOTFIX_PATH="<从记忆中读取>"
KVER="${kver%.custom}"   # kver 从 vmcore sys 输出获取

# 查找修改了特定函数的补丁
grep -rl "function_name" $HOTFIX_PATH/patch/*.patch

# 场景一：查找该版本所有可用热补丁
ls $HOTFIX_PATH/utils/hotfix/*/$KVER/*.ko

# 场景二：查找该版本所有可用热补丁
ls $HOTFIX_PATH/utils/hotfix/*/$KVER/kpatch.0.9.3/*.ko
```

### B.7 定制版 C 详细配置（示例）

**识别特征**：内核版本号格式为 `5.4.32-1_<N>.build`

| 仓库 | 用途 | 地址 |
|------|------|------|
| `custom_kernel_c` | 内核源码 | `git@git.example.com:AcmeCorp/Kernel/custom_kernel_c.git` |
| `custom_hotfix_c` | 热补丁 | `git@git.example.com:AcmeCorp/Kernel/custom_hotfix_c.git` |

**内核版本与 Tag 对应规则**：

格式：`5.4.32-1_<N>.build` → tag `build-5.4.32-1_<N>`（去掉 `.build`，加 `build-` 前缀）

| 内核版本示例 | Tag |
|---------|-----|
| `5.4.32-1_00131.build` | `build-5.4.32-1_00131` |

```bash
# kver 从 vmcore sys 输出获取，以下为提取逻辑示意
tag="build-${kver%.build}"

# checkout 到对应版本
cd custom_kernel_c && git checkout $tag
```

**热补丁检索**：

定制版 C 使用 livepatch 机制，patch 文件在 `patches/x86_64/` 目录下。

```bash
HOTFIX_PATH="<从记忆中读取>"
KVER="build-${kver%.build}"   # 如 build-5.4.32-1_00131

# 查找修改了特定函数的补丁
grep -rl "function_name" $HOTFIX_PATH/patches/x86_64/*.patch

# 查看该版本所有可用热补丁 ko
# ko 路径：utils_x86_64/hotfix/<patch_name>/<kver>/livepatch-<name>.ko
ls $HOTFIX_PATH/utils_x86_64/hotfix/*/$KVER/*.ko
```

---

## 参考文档索引

| 文档 | 在线地址 |
|------|---------|
| **Crash Utility 白皮书** | https://crash-utility.github.io/crash_whitepaper.html |
| **Crash Utility GitHub 仓库** | https://github.com/crash-utility/crash |
| **Kdump 官方文档** | https://www.kernel.org/doc/html/latest/admin-guide/kdump/kdump.html |
| **VMCOREINFO 官方文档** | https://www.kernel.org/doc/html/latest/admin-guide/kdump/vmcoreinfo.html |
| **Intel SDM（软件开发人员手册）** | https://www.intel.cn/content/www/cn/zh/support/articles/000006715/processors.html |
| **Intel SDM 合并卷 PDF** | https://www.intel.com/content/dam/www/public/us/en/documents/manuals/64-ia-32-architectures-software-developer-vol-3a-part-1-manual.pdf |
| **Red Hat 内核转储分析指南** | https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/managing_monitoring_and_updating_the_kernel/analyzing-a-core-dump |
| **Rocky Linux Crash Analysis 指南** | https://docs.rockylinux.org/10/guides/kernel/crash_analysis/ |
