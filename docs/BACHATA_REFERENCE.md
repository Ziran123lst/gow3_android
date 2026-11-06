# 参考来源说明：Bachata-S4-Plus

本增强包以 **`erickmendes22/Bachata-S4-Plus`** 为参考对象（已 fork 到 `Ziran123lst/Bachata-S4-Plus`），借鉴它"在 Android 上如何让 PS4 游戏跑起来 / 变可玩"的工程经验。**主题始终是 gow3（SpartanPort 原生移植）**，Bachata 仅作方法论来源。

## 技术谱系（据 Bachata README）

```
shadPS4
   └── PlayStation 4 模拟技术
          ├── ARM64 / 移动端开发
          └── Bachata S4
                 └── Bachata S4+  (社区修改, FEX/Box64 后端)

FEX-Emu / Box64  ──>  ARM64 上的 x86-64 执行层
```

gow3_android（SpartanPort）同样建立在 shadPS4（GPU）与 FEX-Emu（CPU）之上，但走**原生端口**路线（C++ 重写 Orbis 运行时 + 签名补丁），而非 Bachata 的 APK Smali 修改路线。

## 借鉴了什么

| 借鉴点 | 落到 gow3 的位置 | 来源 |
|---|---|---|
| 兼容性哲学（修目标问题 / 避免全局回退 / 可复现） | `docs/PATCHING_PHILOSOPHY.md` | Bachata README · Compatibility Philosophy |
| 跨设备兼容性数据库模板 | `docs/COMPATIBILITY.md` | Bachata `docs/compatibility.md` |
| 上游 shadPS4 `IT_SET_PREDICATION` 实现（遮挡查询/条件渲染） | `scripts/apply-v20-predication.sh` | Bachata `runtime/v20/` |

## 因抽象层不同，**不可直接复用**的 Bachata 资产

- **`tmp-minport-smali/`**（Android app 层 Smali 反编译，如 `ImportService` 导入流程）—— gow3 是 C++ 原生端口，不共享 app 层；仅作"导入/安装流程"思路参考。
- **`tools/save-manager-*`**（Smali 存档模组）—— gow3 用 `scripts/save_import.py` / `scripts/save_backup.py`（C++ 桥接）替代，不搬运 Smali。
- **Box64 执行后端** —— gow3 主线仅 FEXCore；Bachata 的 Box64 实验路径不在 gow3 主线。

## gow3 已具备、故本包未重写的对应能力

手柄 `controller_mappings.py` / `controller_diagrams/` · 存档 `save_import.py` / `save_backup.py` · 诊断 `texture_diagnostics.py` · 补丁 `patches.py` / `verify_game_patches.py` / `PATCHES.md` · 图形 `graphics_options.py` / `upscaler.md` / `ultrawide.md` / `DEPTH_ADAPTIVE_TAA.md` · 高帧率 `docs/high-fps/` · 启动 `launch_env.py` + Rust launcher (`docs/specs/*rust*`)。

## V20 predication 补丁用法

```bash
cd gow3_android
bash scripts/apply-v20-predication.sh          # 默认从仓库根，作用于 gpu/shadps4
# 或指定仓库根： bash scripts/apply-v20-predication.sh /path/to/gow3_android
```

脚本会：进入 `gpu/shadps4` → 若无 git 历史则初始化独立基线仓库 → fetch 上游 shadPS4 commit `3559530…` → cherry-pick `IT_SET_PREDICATION` 实现 → 按允许列表解决冲突 → 硬验证关键符号 → 删除临时 `.git` 使改动回到父仓库 working tree。

> 前置：需能访问 `github.com/shadps4-emu/shadPS4.git`；若 `gpu/shadps4` 已含 predication 实现，cherry-pick 冲突即"已包含"信号，按提示跳过。
