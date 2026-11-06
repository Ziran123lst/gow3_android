#!/usr/bin/env bash
# =============================================================================
# apply-v20-predication.sh   (gow3_android / SpartanPort)
#
# 把 Bachata-S4-Plus 的 "V20" 补丁（上游 shadPS4 的 IT_SET_PREDICATION 实现）
# 移植应用到 gow3_android 的 vendored shadPS4 视频核心 (gpu/shadps4)。
# 这是从 Bachata-S4-Plus 借鉴到 gow3 的**唯一代码级 GPU 增强**，用于修复
# God of War III Remastered 的遮挡/可见性问题。
#
# 来源: erickmendes22/Bachata-S4-Plus  runtime/v20/apply-full-predication.sh
# 上游: https://github.com/shadps4-emu/shadPS4  commit 3559530df5aec4067a95912af13ef14896b65ada
#       "video_core: Implement IT_SET_PREDICATION using VK_EXT_conditional_rendering"
#
# 与 Bachata 原脚本的区别:
#   gow3_android 的 gpu/shadps4 是 *vendored 快照*（非 git submodule，无 shadPS4 历史）。
#   因此本脚本在 gpu/shadps4 内 git init 一个独立仓库作为基线，fetch 目标 commit 后
#   cherry-pick；结束前删除该临时 .git，使改动以普通文件形式回到 gow3_android 父仓库
#   的 working tree，供父仓库统一 commit。
#
# 用法:
#   bash scripts/apply-v20-predication.sh [GOW3_REPO_ROOT]
#   （默认 GOW3_REPO_ROOT=. ，即从 gow3_android 仓库根调用）
# =============================================================================
set -euo pipefail

PATCH_COMMIT=3559530df5aec4067a95912af13ef14896b65ada
UPSTREAM_URL=https://github.com/shadps4-emu/shadPS4.git

ROOT="${1:-.}"
SHAD_DIR="$ROOT/gpu/shadps4"

if [[ ! -d "$SHAD_DIR" ]]; then
  echo "找不到 gpu/shadps4 目录: $SHAD_DIR" >&2
  echo "请传入 gow3_android 仓库根路径。" >&2
  exit 2
fi

cd "$SHAD_DIR"

# --- 若没有 git 历史，建立独立基线仓库（嵌套 .git，与父仓库隔离）---
if [[ ! -d .git ]]; then
  echo "gpu/shadps4 无 git 历史，初始化独立基线仓库…"
  git init -q
  git config user.email "bachata-integration@local"
  git config user.name  "bachata-integration"
  git add -A
  git commit -qm "baseline: vendored shadPS4 snapshot (for V20 cherry-pick)"
fi

# --- 拉取上游目标 commit ---
git remote remove shadps4-upstream >/dev/null 2>&1 || true
git remote add shadps4-upstream "$UPSTREAM_URL"

git -c fetch.recurseSubmodules=false \
    fetch --no-tags --no-recurse-submodules \
    shadps4-upstream "$PATCH_COMMIT"

# --- cherry-pick（不自动提交，便于冲突处理）---
set +e
git -c submodule.recurse=false cherry-pick --no-commit "$PATCH_COMMIT"
rc=$?
set -e

if (( rc != 0 )); then
  echo "V20: cherry-pick 冲突；按 Bachata 已知渲染器冲突列表解决。"

  conflicts="$(git diff --name-only --diff-filter=U || true)"
  printf '%s\n' "$conflicts"

  allowed_conflicts=(
    src/video_core/amdgpu/liverpool.cpp
    src/video_core/amdgpu/liverpool.h
    src/video_core/renderer_vulkan/vk_instance.cpp
    src/video_core/renderer_vulkan/vk_instance.h
    src/video_core/renderer_vulkan/vk_rasterizer.h
  )

  is_allowed() {
    local f="$1" x
    for x in "${allowed_conflicts[@]}"; do
      [[ "$f" == "$x" ]] && return 0
    done
    return 1
  }

  while IFS= read -r f; do
    [[ -z "$f" ]] && continue
    if ! is_allowed "$f"; then
      echo "非预期冲突: $f" >&2
      exit 23
    fi
    # cherry-pick 期间：--theirs = predication commit 版本
    git checkout --theirs -- "$f"
    git add "$f"
  done <<< "$conflicts"

  git add CMakeLists.txt \
          src/video_core/amdgpu/pm4_cmds.h \
          src/video_core/host_shaders/CMakeLists.txt \
          src/video_core/host_shaders/occlusion_predicate.comp \
          src/video_core/renderer_vulkan/vk_predication.cpp \
          src/video_core/renderer_vulkan/vk_predication.h \
          src/video_core/renderer_vulkan/vk_rasterizer.cpp || true
fi

if git diff --name-only --diff-filter=U | grep -q .; then
  echo "仍有未解决的 V20 冲突:" >&2
  git diff --name-only --diff-filter=U >&2
  exit 24
fi

# --- 硬验证（关键符号必须存在，旧警告必须消失）---
test -f src/video_core/renderer_vulkan/vk_predication.cpp
test -f src/video_core/renderer_vulkan/vk_predication.h
test -f src/video_core/host_shaders/occlusion_predicate.comp
grep -R -q 'beginConditionalRenderingEXT' src/video_core/renderer_vulkan
grep -R -q 'copyQueryPoolResults'      src/video_core/renderer_vulkan
grep -R -q 'QueryType::eOcclusion'     src/video_core/renderer_vulkan
grep -q 'EnableFromZpass'              src/video_core/amdgpu/liverpool.cpp
grep -q 'RestorePredicatedIndexBase'   src/video_core/amdgpu/liverpool.cpp

if grep -q 'LOG_WARNING(Render, "Unimplemented IT_SET_PREDICATION");' \
       src/video_core/amdgpu/liverpool.cpp; then
  echo "遗留的 SET_PREDICATION 旧实现仍然存在。" >&2
  exit 25
fi

# --- 清理临时独立仓库，使改动回到父仓库 working tree ---
rm -rf .git
echo "V20 predication 移植成功（已暂存文件改动于 gpu/shadps4）。"
echo "请在 gow3_android 父仓库执行： git add gpu/shadps4 && git commit -m 'gpu/shadps4: port V20 IT_SET_PREDICATION (from Bachata-S4-Plus)'"
git status --short || true
