# BuWai AI Extension - 完整安装/卸载系统

## 快速开始

### 安装扩展到 OpenCode

```bash
./install.sh
```

这会：
1. 检测 OpenCode 配置目录（`~/.config/opencode`）
2. 复制扩展文件到 OpenCode
3. 给复制的文件添加 `extension-id` 元数据
4. 创建安装记录

### 卸载扩展

```bash
./uninstall.sh
```

这会：
1. 读取安装记录
2. 从 OpenCode 删除扩展文件
3. 清理安装记录

---

## 文档

- **FINAL_SOLUTION.md** - 完整的问题解答和解决方案
- **ANSWERS.md** - 三个问题的详细答案
- **README.md** - 项目说明

---

## 三个关键问题解答

### Q1：忘记写 extension-id 会重复添加吗？

**A**：不会。安装脚本会检查是否已有 `extension-id`，有则跳过。✅

### Q2：安装到 OpenCode 目录了吗？

**A**：是的。新实现会复制文件到 `~/.config/opencode`。✅

### Q3：具备安装能力吗？

**A**：是的。新实现会复制文件、添加元数据、创建记录。✅

---

## 元数据系统

使用 `extension-id` 元数据标识扩展：

```yaml
---
description: Translate English markdown documents to Chinese
extension-id: buwai-ai-extension
---

# Command content...
```

**优势**：
- ✅ 不会与 OpenCode 冲突（会被忽略）
- ✅ 不会与 Claude Code 冲突（不在处理列表中）
- ✅ 嵌入文件中，不会丢失
- ✅ 可以版本控制

---

## 文件说明

- **install.sh** - 安装脚本（复制到 OpenCode）
- **uninstall.sh** - 卸载脚本（从 OpenCode 删除）
- **.extension-install** - 安装记录（git 忽略）
- **.gitignore** - 包含安装记录忽略规则

---

## 详细文档

查看 **FINAL_SOLUTION.md** 了解：
- 完整的工作流程
- 系统架构
- 使用示例
- 与原系统的对比
- 安全机制

---

## 命令选项

### 安装

```bash
./install.sh                           # 基本安装
./install.sh --extension-id my-ext      # 自定义扩展 ID
./install.sh --verify-only            # 仅验证，不安装
./install.sh --help                   # 查看帮助
```

### 卸载

```bash
./uninstall.sh                        # 基本卸载
./uninstall.sh --extension-id my-ext    # 指定扩展 ID
./uninstall.sh --dry-run              # 预览删除
./uninstall.sh --force                # 强制卸载（跳过确认）
./uninstall.sh --help                 # 查看帮助
```

---

## 系统特性

✅ **真正的安装**：复制文件到 OpenCode  
✅ **智能卸载**：基于元数据识别  
✅ **防止重复**：检查已有元数据  
✅ **安全机制**：确认提示、dry-run 模式  
✅ **无冲突**：`extension-id` 不会与 OpenCode/Claude Code 冲突  
✅ **完整追踪**：安装记录文件  
✅ **用户友好**：彩色输出、详细提示

---

**系统已完全实现并测试通过！**
