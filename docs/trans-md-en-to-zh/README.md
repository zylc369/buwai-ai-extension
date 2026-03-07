# Markdown 英文到中文翻译工具

基于 OpenCode 的智能文档翻译系统，支持将英文 Markdown 文档准确翻译为中文，并提供高级的增量翻译和验证功能。

## 功能特点

- **智能翻译**：精准翻译英文 Markdown 文档，保持格式和结构完整
- **链接处理**：自动检测并替换内部 Markdown 链接为对应中文版本
- **目录翻译**：支持单个文件或整个目录的批量翻译
- **增量翻译**：基于 Git 变更的增量翻译，仅处理修改的文件
- **验证模式**：验证现有翻译的准确性、术语一致性和格式完整性
- **链接替换**：自动更新翻译文件中的内部链接
- **术语一致性**：维护整个文档翻译过程中的术语一致性
- **格式保留**：完整保留 Markdown 结构、代码块和语法

## 工作流程

### 基础翻译流程

1. **输入检测**：识别输入为单个文件或目录
2. **语言验证**：检查文件是否为英文文档
3. **链接分析**：解析文档中的所有内部 Markdown 链接
4. **翻译执行**：执行准确的中文翻译
5. **链接更新**：替换链接为对应的中文版本
6. **文件生成**：生成 `.zh-cn.md` 后缀的翻译文件

### Git 增量翻译流程（高级功能）

1. **记录检查**：检查是否存在 `translation-en-to-zh-record.md` 记录文件
2. **变更检测**：对比 Git 提交，识别新增、修改或删除的文件
3. **增量处理**：
   - 新增文件：执行翻译
   - 修改文件：重新翻译
   - 删除文件：移除对应的中文版本
4. **记录更新**：更新翻译记录文件

## 系统要求

- [OpenCode](https://opencode.ai) 环境
- 支持的 AI 模型（包括免费模型）
- Git 环境（用于增量翻译功能）

## 安装方法

### 1. 克隆仓库

```bash
git clone <repository-url>
cd buwai-ai-extension
```

### 2. 全局安装（可选）

将 `extensions/commands/trans-md-en-to-zh.md` 拷贝到 `~/.config/opencode/commands/trans-md-en-to-zh.md`。

**快捷命令：** `cp extensions/commands/trans-md-en-to-zh.md ~/.config/opencode/commands/trans-md-en-to-zh.md`

如果不想全局安装，可以直接在 `buwai-ai-extension` 目录下启动 opencode，进而快速体验。

## 使用方法

### 基本用法

在 OpenCode 中运行翻译命令：

```
/translate-md-en-to-zh [路径] [模式] [递归]
```

### 参数说明

- `[路径]`（必需）：文件或目录路径
  - **文件**：翻译单个 Markdown 文件（需为英文）
  - **目录**：翻译该目录中的所有英文 Markdown 文件

- `[模式]`（可选，默认：`trans`）：
  - `trans`：翻译英文为中文
  - `verify`：验证现有翻译的准确性并修复问题

- `[递归]`（可选，默认：`true`）：
  - `true`：翻译目录及其所有子目录
  - `false`：仅翻译指定目录（单文件时忽略）

### 示例

```bash
# 翻译单个文件
/translate-md-en-to-zh README.md

# 翻译整个目录
/translate-md-en-to-zh docs/

# 使用验证模式
/translate-md-en-to-zh docs/ verify

# 非递归翻译
/translate-md-en-to-zh docs/ trans false
```

### 输出规则

- 翻译文件使用 `.zh-cn.md` 后缀
- 示例：`README.md` → `README.zh-cn.md`
- 示例：`docs/guide.md` → `docs/guide.zh-cn.md`

## 高级功能

### 1. 链接自动替换

翻译过程中，命令自动检测指向其他英文 Markdown 文件的链接：

- **存在中文版本**：将链接替换为 `file.zh-cn.md`
- **不存在中文版本**：保持原始链接不变

**示例：**
```markdown
<!-- 英文原文 -->
[文档](./guide.md)

<!-- 翻译后（如果 guide.zh-cn.md 存在） -->
[文档](./guide.zh-cn.md)
```

### 2. 验证模式

使用 `verify` 模式审查现有翻译：

- 检查翻译准确性
- 验证术语一致性
- 修复格式问题
- 更新损坏的链接

### 3. Git 增量翻译

支持基于 Git 变更的增量翻译，提高大型代码库的翻译效率：

#### 翻译记录文件

- **位置**：被翻译目录的根目录
- **文件名**：`translation-en-to-zh-record.md`

#### 记录文件格式

```markdown
# translation-en-to-zh 命令执行记录

## Git 提交 ID
[Git commit hash]

## 翻译文档映射
1. [英文文档链接] -> [中文文档链接]. 翻译时间: [YYYY/MM/DD HH:MM:SS]
2. [英文文档链接] -> [中文文档链接]. 翻译时间: [YYYY/MM/DD HH:MM:SS]
...

## 翻译完成时间
[YYYY/MM/DD HH:MM:SS]
```

#### 变更检测算法

1. 获取提交范围：从记录中的提交到当前提交
2. 列出变更文件：`git diff --name-only {from_commit} {to_commit} -- "*.md"`
3. 分类变更：
   - 新增：翻译为 `{filename}.zh-cn.md`
   - 修改：重新翻译 `{filename}.zh-cn.md`（覆盖）
   - 删除：删除 `{filename}.zh-cn.md`（如果存在）

### 4. 翻译规则

1. **准确性**：精准翻译，不添加源文中不存在的内容
2. **链接处理**：检查链接的英文 Markdown 文件是否有中文版本，相应替换
3. **格式保留**：保留 Markdown 结构、代码块和语法
4. **术语一致性**：在整个翻译过程中保持术语一致

## 错误处理

- **非英文文档**：显示错误"这不是一个英文 Markdown 文档，无法翻译！"
- **目录无英文文档**：显示错误"此目录中没有英文文档！"
- **无变更需翻译**：显示"翻译结果已是最新版本。使用 'verify' 模式验证翻译。"

## 最佳实践

### 1. 翻译前提交

```bash
git add .
git commit -m "翻译前更新文档"
/translate-md-en-to-zh docs/
```

### 2. 定期验证

主要文档更新后，使用验证模式：
```bash
/translate-md-en-to-zh docs/ verify
```

### 3. 保持记录在版本控制中

提交 `translation-en-to-zh-record.md` 以跟踪翻译历史：
```bash
git add translation-en-to-zh-record.md
git commit -m "更新翻译记录"
```

### 4. 处理冲突

如果翻译文件出现 Git 合并冲突：
- 先解决英文文件的冲突
- 重新翻译冲突的文件
- 更新翻译记录

## 技术特点

- **高精度**：利用先进的 AI 模型确保翻译质量
- **高效增量**：仅翻译变更的文件，大幅节省时间
- **智能链接**：自动维护文档间的链接关系
- **格式保护**：完整保留 Markdown 结构和代码块
- **术语一致**：维护整个项目的术语统一性
- **成本优化**：支持使用免费的 AI 模型

## 故障排除

### 问题："翻译结果已是最新版本"

**原因**：自上次翻译以来没有 Git 变更

**解决**：使用验证模式验证现有翻译
```bash
/translate-md-en-to-zh docs/ verify
```

### 问题：找不到链接文件的中文版本

**原因**：链接替换逻辑无法找到 `.zh-cn.md` 文件

**解决**：
1. 先翻译链接的文件
2. 或如果不需要翻译，手动更新链接

### 问题：Git 历史变更

**原因**：变基或强制推送更改了提交 ID

**解决**：
1. 删除 `translation-en-to-zh-record.md`
2. 重新运行完整翻译
3. 提交新记录

## 集成 CI/CD

### 自动翻译工作流

```yaml
# GitHub Actions 示例
- name: 检查文档变更
  run: |
    git diff --name-only ${{ github.event.before }} ${{ github.event.after }} | grep "docs/.*\.md$"

- name: 运行翻译
  if: success()
  run: |
    /translate-md-en-to-zh docs/

- name: 验证翻译
  run: |
    /translate-md-en-to-zh docs/ verify
```

## 项目结构

```
buwai-ai-extension/
├── extensions/
│   └── commands/
│       └── trans-md-en-to-zh.md               # 翻译命令定义
│       └── trans-md-en-to-zh-assets/
│           ├── translation-workflow.md           # 增量翻译工作流指南
│           └── OPTIMIZATION_SUMMARY.md         # 优化说明
├── docs/
│   └── trans-md-en-to-zh/
│       └── README.md                          # 本文档
├── install.sh                               # 安装脚本
└── uninstall.sh                             # 卸载脚本
```

## 相关技能

为实现模块化实现，可拆分为以下技能：

1. **incremental-translate**：基于 Git 的变更检测和翻译
2. **replace-markdown-links**：更新内部 Markdown 链接
3. **generate-translation-record**：创建和管理翻译记录

每个技能可独立调用或组合使用以处理复杂工作流。

## 高级工作流（基于 Git 的增量翻译）

有关使用基于 Git 的增量翻译、记录管理和变更检测的生产环境工作流，请参阅[翻译工作流指南](../extensions/commands/trans-md-en-to-zh-assets/translation-workflow.md)。

## 许可证

本项目采用 Apache License 2.0 许可证。

## 联系方式

如有问题或建议，请通过 GitHub Issues 联系。
