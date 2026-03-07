# AI Extension Installation System - 完整解决方案

## 问题确认和解决

### 问题1：忘记写 extension-id 标签是否会重复添加？

**答案：不会重复添加** ✅

**实现机制**：
```bash
has_extension_metadata() {
    local file="$1"
    local ext_id="$2"
    # 检查文件中是否已有 extension-id
    grep -q "^extension-id: $ext_id" "$file" 2>/dev/null
}

add_extension_metadata() {
    # 如果已有，直接返回
    if has_extension_metadata "$file" "$ext_id"; then
        return 0
    fi
    # 否则添加
    ...
}
```

**工作流程**：
1. 第一次安装：添加 `extension-id`
2. 第二次安装：检测到已有，跳过添加
3. 结果：只添加一次 ✅

---

### 问题2：OpenCode 的安装目录在 `~/.config/opencode`，是否安装到了这里？

**原实现：❌ 没有安装到 OpenCode**

- 只操作当前项目的 `extensions/` 目录
- 没有复制到 `~/.config/opencode`
- 不是真正的安装

**新实现：✅ 安装到 OpenCode**

**检测的目录**：
```bash
$HOME/.config/opencode  # OpenCode 主目录
$HOME/.opencode        # 备用目录
$HOME/.openclaw       # 另一个可能的目录
$XDG_CONFIG_HOME/opencode  # XDG 标准目录
```

**安装流程**：
1. 检测 OpenCode 目录
2. 创建 `commands/` 和 `skills/` 子目录
3. 复制文件到 OpenCode
4. 给复制的文件添加 `extension-id`

---

### 问题3：没有文件拷贝命令，如何安装的？是否具备安装能力？

**原实现：❌ 不具备安装能力**

- 只是给本地文件添加元数据
- 没有复制文件到任何地方
- 不是真正的"安装"，只是"打标签"

**新实现：✅ 完整的安装/卸载系统**

#### 安装能力

```bash
./install.sh
```

**完整的安装流程**：

1. ✅ **验证源扩展**：检查当前项目的 `extensions/`
2. ✅ **检测 OpenCode**：查找配置目录
3. ✅ **创建目录**：如果需要，创建 `commands/` 和 `skills/`
4. ✅ **复制文件**：从项目复制到 OpenCode
5. ✅ **添加元数据**：给**复制的文件**添加 `extension-id`
6. ✅ **创建记录**：保存安装信息

#### 卸载能力

```bash
./uninstall.sh
```

**完整的卸载流程**：

1. ✅ **读取记录**：从 `.extension-install` 读取安装信息
2. ✅ **验证 ID**：确认扩展 ID 匹配
3. ✅ **扫描目录**：在 OpenCode 中查找匹配的文件
4. ✅ **显示列表**：列出将要删除的文件
5. ✅ **请求确认**：用户确认后才删除
6. ✅ **删除文件**：从 OpenCode 删除扩展
7. ✅ **清理记录**：删除安装记录

---

## 系统架构

### 文件结构

**项目目录**：
```
buwai-ai-extension/
├── extensions/              # 源扩展文件
│   ├── commands/           # 命令定义
│   └── skills/             # 技能定义
├── install.sh              # 安装脚本
├── uninstall.sh            # 卸载脚本
├── .extension-install      # 安装记录（git 忽略）
└── README.md
```

**OpenCode 目录**：
```
~/.config/opencode/
├── commands/              # 已安装的命令
│   ├── trans-md-en-to-zh.md
│   └── trans-md-en-to-zh-assets/
└── skills/                # 已安装的技能
```

### 安装记录文件

`.extension-install` 文件内容：

```bash
# Extension Installation Record
# DO NOT DELETE - Used for uninstallation

EXTENSION_ID="buwai-ai-extension"
INSTALL_DATE="2026-03-07T12:30:00Z"
INSTALL_DIR="/Users/user/.config/opencode"
FILES_COUNT="5"
VERSION="1.0.0"
```

**作用**：
- 记录扩展安装位置
- 保存扩展 ID
- 用于卸载时定位文件
- 防止误删其他扩展

---

## 使用示例

### 基本安装

```bash
./install.sh
```

输出：
```
========================================
AI Extension Installer
========================================

✓ Source extension validated: 1 file(s) found
Found OpenCode directory: /Users/user/.config/opencode
Created directory: /Users/user/.config/opencode/commands

Copying command files...
  [DONE] trans-md-en-to-zh.md
  [DONE] trans-md-en-to-zh-assets/

Copying skill files...

✓ Installation record created: .extension-install

========================================
Extension Installation Complete!
========================================

Extension Information:
  ID: buwai-ai-extension
  Source: /Users/user/project/extensions
  Installed to: /Users/user/.config/opencode
  Files copied: 2
========================================
```

### 卸载

```bash
./uninstall.sh
```

输出：
```
========================================
AI Extension Uninstaller
========================================

ℹ Reading installation record...
ℹ Extension ID: buwai-ai-extension
ℹ Install directory: /Users/user/.config/opencode

ℹ Scanning for extension files...

Files and folders to be removed:
FILES:
  /Users/user/.config/opencode/commands/trans-md-en-to-zh.md
FOLDERS:
  /Users/user/.config/opencode/commands/trans-md-en-to-zh-assets

This will uninstall the extension and remove all its files from OpenCode.

Are you sure you want to uninstall? (yes/no): yes

ℹ Removing files and folders...
✓ Removed folder: /Users/user/.config/opencode/commands/trans-md-en-to-zh-assets
✓ Removed file: /Users/user/.config/opencode/commands/trans-md-en-to-zh.md
✓ Removed installation record: .extension-install

========================================
Uninstallation Complete!
========================================
```

### Dry-run 模式

```bash
./uninstall.sh --dry-run
```

只显示将要删除的文件，不实际删除。

---

## 元数据系统

### 字段命名：`extension-id`

**选择原因**：
- ✅ 更明确：`id` 表示标识符
- ✅ 避免冲突：不与未来可能的 `extension` 字段冲突
- ✅ 遵循规范：kebab-case 命名
- ✅ 兼容性：OpenCode 会忽略未知字段

**格式**：
```yaml
---
description: 命令描述
extension-id: buwai-ai-extension
---

# 命令内容...
```

---

## 安全机制

### 1. 元数据检查

- 检查是否已有 `extension-id`
- 防止重复添加
- 精确匹配，避免误删

### 2. 安装记录

- 保存安装位置
- 保存扩展 ID
- 用于卸载定位
- 防止误删其他扩展

### 3. 确认提示

- 默认需要用户确认
- 可以用 `--force` 跳过
- 防止误操作

### 4. Dry-run 模式

- 预览要删除的文件
- 不实际删除
- 便于验证

---

## 与原系统对比

| 特性 | 原实现 | 新实现 |
|------|--------|--------|
| **安装位置** | 当前项目目录 | `~/.config/opencode` ✅ |
| **文件操作** | 只添加元数据 | 复制 + 添加元数据 ✅ |
| **真正安装** | ❌ 否 | ✅ 是 |
| **卸载能力** | 删除本地文件 | 从 OpenCode 删除 ✅ |
| **安装记录** | ❌ 无 | `.extension-install` ✅ |
| **安装追踪** | ❌ 无 | 完整记录 ✅ |
| **ID 冲突检查** | ✅ 有 | ✅ 有 |
| **安全机制** | 确认提示 | 确认 + dry-run ✅ |

---

## 总结

### 三个问题的最终答案

| 问题 | 答案 | 状态 |
|------|------|------|
| **Q1**：忘记写 extension-id 会重复添加吗？ | 不会，有检查机制 | ✅ 已实现 |
| **Q2**：安装到 OpenCode 了吗？ | 旧：❌ 否<br>新：✅ 是 | ✅ 已修复 |
| **Q3**：具备安装能力吗？ | 旧：❌ 否<br>新：✅ 是 | ✅ 已实现 |

### 核心改进

1. ✅ **真正的安装**：复制到 OpenCode 目录
2. ✅ **完整追踪**：安装记录文件
3. ✅ **智能卸载**：基于记录和元数据
4. ✅ **安全保障**：多层级安全机制
5. ✅ **元数据系统**：`extension-id` 无冲突

### 系统现状

- ✅ 具备完整的安装能力
- ✅ 具备完整的卸载能力
- ✅ 安装到正确的 OpenCode 目录
- ✅ 防止重复添加元数据
- ✅ 不会与 OpenCode/Claude Code 冲突

**系统现在完全可用，可以提供给 OpenCode 使用！**
