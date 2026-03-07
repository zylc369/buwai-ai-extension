# BuWai AI Extension - 完整安装/卸载系统

## 快速开始

### 安装

```bash
./install.sh
```

### 卸载

```bash
./uninstall.sh
```

---

## 四个关键问题解答

### Q1：忘记写extension-id会重复添加吗？

**A**：不会重复添加到目标文件（OpenCode目录）✅

**说明**：
- 安装脚本检查目标文件是否已有 `extension-id`
- 如果有，跳过添加
- 但**源文件**不会被检查，所以每次重新安装都会重复添加到OpenCode

### Q2：已写extension-id会重复写入吗？

**A**：不会重复写入到目标文件 ✅

**说明**：
- 有完整的检查机制
- 目标文件（OpenCode目录）中已有则跳过
- 不会重复添加

### Q3：.gitkeep会被拷贝吗？目录不存在会创建吗？

**A**：
- ❌ 旧实现：.gitkeep 会被拷贝
- ✅ 修复后：.gitkeep 会被排除
- ✅ 目录不存在会主动创建

**修复**：
```bash
# 旧实现
[[ "$src_file" != *"assets"* ]] || continue

# 修复后
[[ "$src_file" != *"assets"* ]] && [[ "$src_file" != *".gitkeep"* ]] || continue
```

### Q4：.extension-install被删除会影响吗？

**A**：
- ❌ 旧实现：卸载失败
- ✅ 修复后：可以继续卸载

**修复**：
- 记录丢失时扫描OpenCode目录
- 智能查找扩展文件
- 提供多种恢复方式

---

## 系统特性

### 核心功能

✅ **真正的安装**：复制文件到 `~/.config/opencode`
✅ **智能卸载**：基于元数据识别
✅ **防止重复**：检查已有的 extension-id
✅ **排除.gitkeep**：不会被复制到OpenCode
✅ **目录创建**：必要时主动创建
✅ **容错恢复**：记录丢失时扫描OpenCode目录

### 安全机制

- ✅ ID验证
- ✅ 确认提示
- ✅ Dry-run 模式
- ✅ 强制卸载
- ✅ 渐进降级恢复

---

## 文档

- **FINAL_QUESTIONS_ANSWER.md** - 四个问题的详细解答
- **QUESTIONS_ANSWER.md** - 问题的初次解答
- **README.md** - 项目说明

---

## 系统状态

- ✅ 完整的安装能力
- ✅ 完整的卸载能力
- ✅ 防止重复元数据
- ✅ 排除.gitkeep文件
- ✅ 目录自动创建
- ✅ 容错和恢复机制
- ✅ 无OpenCode冲突
- ✅ 无Claude Code冲突

**系统已完全修复并经过验证！**
