# 补丁与扩展开发哲学（参考 Bachata 兼容性哲学）

> 本文件把 `Bachata-S4-Plus` README 中的 **Compatibility Philosophy** 提炼为 gow3_android（SpartanPort）**补丁与扩展开发准则**。
> gow3 已有成熟的签名补丁体系（`patches/CUSA01623.xml`、`scripts/patches.py`、`scripts/verify_game_patches.py`、`docs/PATCHES.md`），本哲学用于**保持该体系在扩展时的质量**。

Bachata 提出一条兼容性修复应满足三条要求，gow3 据此对齐如下。

## 1. 修复目标问题（Fix the target problem）

补丁必须对受影响游戏 / 子系统产生**可测量的改善**。

- gow3 现状：`docs/PATCHES.md` 中每个内置补丁都有明确"它做什么"（如 Startup Black Screen、Texture Corruption Fix、Skip Video、Resolution / Frame Rate Patch），且 `scripts/verify_game_patches.py` 用于验证补丁可应用。
- 准则：新增补丁时，必须在 `docs/PATCHES.md` 写清"修复了什么、如何验证"，并用 `verify_game_patches.py` 确认其可在目标 build 上命中签名。

## 2. 避免全局回退（Avoid global regressions）

> *"A fix for one title should not cause regressions in unrelated games."*

一个游戏的修复**不应**搞坏其他游戏 / 其他 build。

- gow3 现状：`patches/CUSA01623.xml` 的站点**按签名（原字节）定位**，因此只对"代码匹配"的 build 生效；补丁在游戏启动时**写入内存副本**，从不修改游戏文件夹（`docs/PATCHES.md`）。
- 准则：
  - **按签名定位，不按硬编码偏移**：新增补丁必须提供原始字节签名，避免在其他版本上误改。
  - **隔离作用域**：游戏特定修复默认只对匹配签名生效；如需全局开关（如第三方 shadPS4 / GoldHEN 补丁），必须在 launcher 中**显式可关**（`docs/PATCHES.md` 的 Third-party patches）。
  - **扩展新游戏时新建档案**：为其他 PS4 游戏做端口时，使用独立的 `patches/<CUSA>.xml` 与 `port-identity.json`，不往 GOW3 的补丁文件里塞无关改动。

## 3. 可复现（Be reproducible）

改动最终必须**文档化**，使其行为可被复现、审查、跨构建对比。

- gow3 现状：`docs/PATCHES.md` 记录每个补丁的作者与开关位置；`scripts/verify_game_patches.py` 提供可复现的验证；`docs/specs/` 保存设计决策。
- 准则：
  - 每个补丁提交必须附带：签名 / 原字节、目标 Title ID 与版本、验证命令输出。
  - 实验性修复若引入回退，应可被移除 / 回滚（见 `docs/incidents/` 的事故记录流程）。
  - GPU 层改动（如 `scripts/apply-v20-predication.sh` 的 predication 移植）须记录上游 commit 与硬验证符号，保证可复现。

## 与 Bachata 的差异提示

- **执行后端**：Bachata 提供 FEX / Box64 可切换预设；gow3 主线仅 FEXCore，不引入 Box64。后端相关准则以 FEXCore 为准。
- **抽象层**：Bachata 的"游戏特定修复"多为 app 层 Smali 修改 / 配置；gow3 是 C++ 原生端口，修复落点为签名补丁（内存写入）或 `src/runtime_*.c` 的 Orbis 库重写。本哲学对两者通用，但实现层不同。

##  checklist（提交补丁 / 扩展前）

- [ ] 有签名 / 原字节，且经 `verify_game_patches.py` 验证可命中目标 build
- [ ] 作用域隔离，不会误改其他版本 / 游戏
- [ ] 在 `docs/PATCHES.md`（或对应文档）写清作用与开关
- [ ] 实验性修复可回滚，必要时记入 `docs/incidents/`
