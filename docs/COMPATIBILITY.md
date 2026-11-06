# GOW3 Android 兼容性矩阵

> 本表追踪 **God of War III Remastered（SpartanPort / gow3_android）** 在 Android ARM64 设备上的可玩性。
> 模板与字段规范参考自 `Bachata-S4-Plus/docs/compatibility.md`，但**主题与数据都针对 GOW3（CUSA01623 / CUSA01715）**。
> gow3 项目原有的发布/事故/设计记录见 `docs/releases/`、`docs/incidents/`、`docs/specs/`，本表是**设备级**入口。

兼容性结果会因以下因素显著变化：

- SpartanPort 版本
- 游戏版本 / 更新
- 设备 / SoC
- GPU 与 Vulkan 驱动（如 Turnip / 厂商驱动）
- Android 版本
- 渲染分辨率（见 `docs/PATCHES.md` 的 Resolution Patch）
- 引擎帧率（60 / 100 / 120 / 144 / 180 / 240，见 `docs/PATCHES.md`）
- 温度 / 散热条件

> 到达可玩（gameplay）**不**等同于从头到尾完全可通关。

---

## 状态图例

| 状态 | 含义 |
|---|---|
| 🟢 Playable | 进入游戏且无明显阻塞性问题 |
| 🟢 Gameplay | 进入游戏，但完整可通关性尚未确认 |
| 🟡 In-Game / Issues | 进入游戏，但有显著图形 / 性能 / 输入 / 稳定性问题 |
| 🟡 Boots | 能启动并到达菜单或序章，但未能进入正常游戏 |
| 🟠 Rendering Issues | 能运行，但画面严重错误 |
| 🟠 Input Issues | 能运行，但控制 / 输入阻碍正常游玩 |
| 🔴 Crash | 在进入预期游戏状态前崩溃 |
| 🔴 No Boot | 无法成功启动 |
| ⚪ Untested | 当前版本尚未测试 |

## 执行后端图例

| 后端 | 含义 |
|---|---|
| FEXCore | gow3_android 主线使用的内嵌 FEX-Emu x86-64→ARM64 执行层 |
| (无 Box64) | gow3 主线不含 Box64 后端（与 Bachata 不同） |

## 推荐报告字段

添加结果时尽量包含：

- 游戏名（应为 God of War III Remastered）
- Title ID / CUSA（CUSA01623 或 CUSA01715）
- 区域 / Region
- 游戏版本
- SpartanPort 版本（如 `v3.0.0-nixport-v1`，见 `docs/releases/`）
- 后端（FEXCore）
- 设备 / SoC
- Android 版本
- GPU 驱动
- 渲染分辨率（来自 `docs/PATCHES.md` 的 Resolution Patch）
- 引擎帧率
- 状态
- 主要问题
- 视频链接
- 备注

## 兼容性列表

### Playable / Gameplay

| Game | Title ID | Game Ver | SpartanPort | Backend | Device / SoC | Driver | Res | FPS | Status | Notes | Video |
|---|---|---:|---:|---|---|---|---|---|---|---|---|
| God of War III Remastered | CUSA01623 | 01.02 | — | FEXCore | — | — | — | — | ⚪ Untested | 待社区在真机回填 | — |

### In-Game With Issues

（空 — 待回填）

### Boots / No Gameplay

（空 — 待回填）

### Rendering Issues

（空 — 待回填）

### Input / Controller Issues

（空 — 待回填）

---

> 本表初始为模板。请在 `arm` 分支的各设备 / 驱动实测后回填真实条目；与 `docs/incidents/` 中记录的具体事故相互引用。
