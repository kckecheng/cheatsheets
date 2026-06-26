---
tags: [moc, cheatsheet]
aliases: ["index", "home", "cheatsheets index"]
type: moc
---
# Cheatsheets — Map of Content

Personal technical cheatsheets, organized by domain. Use the **tag pane** (`#git`, `#linux`, `#network`, `#debug`, `#cheatsheet`) or search aliases to navigate. Each note links to related notes in its *Related* section.

## Git

- [[git_basics]] — reference, config, debug, revisions
- [[git_branch]] — branch, switch, pull, restore
- [[git_log_history]] — log, reflog, move HEAD, search history
- [[git_diff]] — diff diagrams, variants, merge diffs
- [[git_reset_revert]] — reset vs revert vs switch
- [[git_merge]] — merge, mergetool, conflict resolution
- [[git_rebase]] — clean up local history with rebase
- [[git_tag]] — create/list/push/delete tags
- [[git_stash]] — stash workflow
- [[git_cherry_pick]] — cherry-pick commits
- [[git_submodule]] — submodule lifecycle
- [[git_misc]] — credentials, proxy, lazygit, cleanup

## Linux

- [[linux_shell]] — shortcuts, glob, zsh, shell debugging, scripting
- [[linux_text_tools]] — awk, sed, grep, find, sort, read, here-doc, bc
- [[linux_storage]] — SCSI, SAN, LVM, NVMe, I/O scheduler, reservations
- [[linux_process_cpu]] — top, ps, taskset, scheduler, CPU affinity
- [[linux_cgroups]] — cgroup v1/v2 resource control
- [[linux_memory]] — slab, buddy, hugepages, OOM, random numbers
- [[linux_system]] — systemd, journalctl, chrony, kdump, grub, locale
- [[linux_hardware]] — ipmitool, EDAC, initramfs, /proc/interrupts
- [[linux_ssh]] — ssh client config, keys, sshpass
- [[linux_kvm_libvirt]] — virsh, VM lifecycle, CPU/memory tuning
- [[linux_misc]] — openssl CA, nfs IO, IPv4/IPv6 bind, screen record

## Networking

- [[net_basics]] — ss, ethtool, nmap, netcat, nmcli, DNS, rp_filter
- [[net_devices]] — bond, VLAN, MACVLAN, VXLAN, bridge, TUN/TAP, veth
- [[net_tcpdump]] — capture filters and examples
- [[net_switching]] — namespaces, veth, bridge, OVS hands-on demos
- [[net_tc]] — traffic control / qdisc
- [[net_testing]] — iperf, qperf, packetdrill, ethr
- [[net_proxy]] — env vars, xray SOCKS5
- [[net_openvswitch]] — OVS command cheatsheet
- [[net_curl]] — curl basics and examples
- [[net_iptables]] — tables, chains, targets, sample rules

## Debugging & Troubleshooting

- [[debug_gdb]] — breakpoints, watchpoints, TUI, python API, memory
- [[debug_kernel_gdb]] — build kernel, QEMU+gdbserver, IDT/GDT, kcore
- [[debug_crash]] — crash utility, modules, lists, vmcore analysis
- [[debug_binutils]] — objdump, readelf, debuginfo, core files
- [[debug_tracing]] — strace, perf, ftrace, trace-cmd, blktrace

## Languages & Tools

- [[go]] — Golang modules, testing, delve, generics, docker images
- [[vim]] — shortcuts, keymap, macros, digraphs
- [[code_utils]] — package managers, ripgrep, cflow, global, cscope, valgrind
- [[ai]] — LLM, agent protocols, tools
- [[misc]] — principles, Sphinx/RST, Docker, Windows, SQL
- [[switch]] — Brocade / Cisco / Dell SAN switch

## How this vault is organized

- **Flat structure** — all notes live in the root folder.
- **Discovery** — via this MOC, the tag pane, aliases, and backlinks.
- **Frontmatter** — every note has `tags`, `aliases`, `type` (cheatsheet/moc).
- **Links** — `wiki-links` connect related notes; check the *Related* section at the bottom of each note and the **Backlinks** pane in Obsidian.
