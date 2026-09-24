# Luraph VM Devirtualization & Architecture Walkthrough

Live interactive walkthrough: **[https://4fundsagent-source.github.io/luraph-deobfuscator/blog/](https://4fundsagent-source.github.io/luraph-deobfuscator/blog/)**

A comprehensive, reproducible reverse engineering analysis and devirtualization pipeline for modern Luraph bytecode protection (targeting Luraph v14.7 on `variant_01.luau`).

---

## Overview

This repository hosts the interactive technical walkthrough and complete verifiable research artifacts from devirtualizing a real-world Luraph binary:

1. **Structure-of-Arrays (SoA) Prototype Memory Layout**: Dissects the 11-column SoA architecture (`p[1]` through `p[11]`) and compares it with Luraph v15's 32-slot randomized permutation metamaps.
2. **Boundary Hooking**: Intercepts the fully unrolled prototype forest at the deserializer seam (function `t`), recovering all 37 prototypes before VM execution begins.
3. **Continuation Law**: Proves the mathematical dispatch law `effective_PC = target + 1` to shatter 10-hop circular decoy trampoline rings into linear application basic blocks.
4. **Anti-Tamper Isolation**: Explains the structural boundary between Proto 2 (the 4,943-instruction injected Roblox integrity check) and Protos 3–37 (the genuine application payload).
5. **AST Reconstruction & IR Lifting**: Recovers control flow graphs via node-splitting on irreducible multi-entry loops, resolving upvalue capture descriptors (`p[6]`), and emitting runnable, structured Luau.

---

## Hosted Research Artifacts

All artifacts referenced in the walkthrough are hosted in [`artifacts/`](./artifacts/):

| File | Size | Description |
| :--- | :--- | :--- |
| [`artifacts/luraph_variant_01.luau`](./artifacts/luraph_variant_01.luau) | 154 KB | Authentic input obfuscated script (Luraph v14.7). |
| [`artifacts/dump_variant_01.luau`](./artifacts/dump_variant_01.luau) | 159 KB | Memory boundary dumper hook script. |
| [`artifacts/k_table_variant_01.json`](./artifacts/k_table_variant_01.json) | 3.1 KB | Flat 164-item constant pool extracted from runtime memory. |
| [`artifacts/prototype_graph_variant_01.txt`](./artifacts/prototype_graph_variant_01.txt) | 930 KB | Raw serialized prototype graph across all 37 prototypes. |
| [`artifacts/opcode_handlers_stable_variant_01.txt`](./artifacts/opcode_handlers_stable_variant_01.txt) | 226 KB | Symbolic AST opcode handlers for 258 virtual operations. |
| [`artifacts/vm_execution_trace_variant_01.txt`](./artifacts/vm_execution_trace_variant_01.txt) | 1.7 KB | Instruction dispatch and global access execution trace. |
| [`artifacts/luraph_variant_01-raw.lua`](./artifacts/luraph_variant_01-raw.lua) | 72 KB | **Tier 1 Deliverable**: Authentic raw AST lift (0 comments, runnable). |
| [`artifacts/luraph_variant_01-decompiled.lua`](./artifacts/luraph_variant_01-decompiled.lua) | 71.5 KB | **Tier 2 Deliverable**: Coalesced register decompilation (0 comments, runnable). |
| [`artifacts/luraph_variant_01-clean.lua`](./artifacts/luraph_variant_01-clean.lua) | 3.0 KB | **Tier 3 Deliverable**: AI semantic cleanup (0 comments, runnable). |

---

## Execution Verification

All three deliverables are verified runnable with exit code `0` in standard Luau offline runtimes:

```bash
# Verify execution of the cleaned deliverable
custom-luau.exe --executor --run-seconds 10 artifacts/luraph_variant_01-clean.lua

# Verify execution of the structured decompile
custom-luau.exe --executor --run-seconds 10 artifacts/luraph_variant_01-decompiled.lua

# Verify execution of the raw AST lift
custom-luau.exe --executor --run-seconds 10 artifacts/luraph_variant_01-raw.lua
```

---

## Local Development

To view the walkthrough locally:

```bash
python -m http.server 8080 --directory blog
# Open http://localhost:8080/ in your browser
```
