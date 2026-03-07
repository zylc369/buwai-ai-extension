# AI Extension Installation System - 问题解答

## 问题1：如果忘记在命令、SKILL的markdown中写extension-id标签，安装脚本是否会重复添加？

### 答案：不会重复添加 ✅

### 原因

安装脚本中的 `has_extension_metadata()` 函数会检查文件中是否已包含 `extension-id` 字段：

```bash
has_extension_metadata() {
    local file="$1"
    local ext_id="$2"
    grep -q "^extension-id: $ext_id" "$file" 2>/dev/null
}
```

### 工作流程

1. **第一次安装**：
   - 文件中没有 `extension-id`
   - `has_extension_metadata()` 返回 false
   - 添加 `extension-id` 到 frontmatter

2. **第二次安装（忘记已写过）**：
   - 文件中已有 `extension-id`
   - `has_extension_metadata()` 返回 true
   - 跳过添加，返回 0

### 测试

```bash
# 第一次安装：添加 extension-id
./install.sh
# 输出：[DONE] extensions/commands/trans-md-en-to-zh.md

# 第二次安装：跳过（已有 extension-id）
./install.sh  
# 输出：[SKIP] extensions/commands/trans-md-en-to-zh.md (already has metadata)
```

**结论**：即使忘记已写过，也不会重复添加。✅

---

## 问题2：OpenCode的AI扩展安装目录在`~/.config/opencode`，你是否安装到了这里？

### 原实现的问题：❌ 没有安装到 OpenCode

之前的实现只：
- 操作当前目录的 `extensions/` 文件夹
- 添加元数据到本地文件
- **没有复制到 OpenCode 目录**

### 新实现：✅ 真正安装到 OpenCode

新的安装脚本会：

1. **检测 OpenCode 目录**：
   ```bash
   POSSIBLE_OPENCODE_DIRS=(
       "$HOME/.config/opencode"
       "$HOME/.opencode"
       "$HOME/.openclaw"
       "$XDG_CONFIG_HOME/opencode"
   )
   ```

2. **创建必要的目录结构**：
   ```bash
   $HOME/.config/opencode/commands/
   $HOME/.config/opencode/skills/
   ```

3. **复制文件到 OpenCode**：
   ```bash
   # 复制命令
   cp extensions/commands/*.md $HOME/.config/opencode/commands/
   
   # 复制技能
   cp extensions/skills/*.md $HOME/.config/opencode/skills/
   ```

4. **给复制的文件添加元数据**：
   ```bash
   # 在 OpenCode 目录中的文件上添加 extension-id
   add_extension_metadata "$opencode_dir/commands/trans-md-en-to-zh.md" "$extension_id"
   ```

### 安装位置对比

| 系统 | 旧实现 | 新实现 |
|------|--------|--------|
| 安装目录 | 当前项目目录 | `~/.config/opencode/` |
| 文件操作 | 只添加元数据 | 复制 + 添加元数据 |
| 是否真正安装 | ❌ 否 | ✅ 是 |

---

## 问题3：安装脚本里面没有文件拷贝命令，你是如何安装的？是否具备安装能力？

### 原实现的问题：❌ 不具备真正的安装能力

之前的 `install.sh` 只是：
- 给本地文件添加元数据
- 没有复制文件
- 没有安装到 OpenCode

这不是真正的"安装"，只是"打标签"。

### 新实现：✅ 完整的安装能力

新的系统提供了完整的安装/卸载流程：

#### 安装流程

```bash
./install.sh
```

1. **验证源扩展**：检查当前项目的 `extensions/` 目录
2. **查找 OpenCode**：检测 `~/.config/opencode` 等目录
3. **创建目录结构**：如果需要，创建 `commands/` 和 `skills/`
4. **复制文件**：从项目目录复制到 OpenCode
5. **添加元数据**：给**复制的文件**添加 `extension-id`
6. **创建安装记录**：保存安装信息到 `.extension-install`

#### 卸载流程

```bash
./uninstall.sh
```

1. **读取安装记录**：从 `.extension-install` 读取安装信息
2. **验证扩展 ID**：确认要卸载正确的扩展
3. **扫描 OpenCode 目录**：查找带有匹配 `extension-id` 的文件
4. **显示要删除的文件**：列出将要删除的文件和文件夹
5. **请求确认**：默认需要用户确认
6. **删除文件**：从 OpenCode 目录删除扩展文件
7. **清理安装记录**：删除 `.extension-install`

### 安装记录文件

`.extension-install` 文件记录了安装信息：

```bash
# Extension Installation Record
# DO NOT DELETE - Used for uninstallation

EXTENSION_ID="buwai-ai-extension"
INSTALL_DATE="2026-03-07T12:30:00Z"
INSTALL_DIR="/Users/user/.config/opencode"
FILES_COUNT="5"
VERSION="1.0.0"
```

这个文件用于：
- 卸载时知道扩展安装位置
- 验证扩展 ID
- 防止误删其他扩展

---

## 总结

### 三个问题的答案

| 问题 | 答案 | 状态 |
|------|------|------|
| 问题1：是否会重复添加？ | 不会，有检查机制 | ✅ 已解决 |
| 问题2：是否安装到 OpenCode？ | 旧实现：❌ 否<br>新实现：✅ 是 | ✅ 已修复 |
| 问题3：是否具备安装能力？ | 旧实现：❌ 否<br>新实现：✅ 是 | ✅ 已实现 |

### 新系统的核心改进

1. **真正的安装**：复制文件到 OpenCode 目录
2. **安装记录**：保存安装位置和元信息
3. **智能卸载**：基于安装记录和元数据卸载
4. **安全机制**：ID 验证、确认提示、dry-run 模式

### 使用方式

```bash
# 安装到 OpenCode
./install.sh

# 卸载
./uninstall.sh

# 自定义扩展 ID
./install.sh --extension-id my-extension
./uninstall.sh --extension-id my-extension
```

系统现在具备完整的安装和卸载能力！
