# specs - AI 多角色协作工作流

> 通过角色分工避免上下文污染，提升 AI 辅助开发质量

---

## ⚡ 快速开始

先进入 `specs` 目录：

```bash
cd /Users/zm00107ml/Desktop/specs
```

```bash
# 初始化新任务（自动创建目录和提示词）
./tools/task-init.sh <任务编号> <功能名称>

# 示例
./tools/task-init.sh 001 用户登录
./tools/task-init.sh 002 订单管理
```

**然后**：

1. 新开 Cursor 窗口
2. 粘贴 `@新项目启动指引-含PDF.md` 到聊天
3. 告诉 Agent 当前是哪个阶段（如"现在是产品分析阶段"）
4. Agent 自动处理该阶段的工作！

---

## 📚 快速入口

- **[新项目启动指引-含PDF.md](./新项目启动指引-含PDF.md)** ⭐：粘贴到 Cursor + 告知阶段，Agent 自动处理

---

## ⚙️ Cursor MCP 配置（Figma 支持）

### 什么是 MCP？

MCP (Model Context Protocol) 是 Cursor 的扩展协议，允许 AI 访问外部工具和服务。通过配置 Figma MCP Server，AI 可以直接读取 Figma 设计稿信息。

### 配置步骤

**1. 安装 Cursor 浏览器扩展**

访问 Chrome 应用商店，搜索并安装 "Cursor Browser Extension"

**2. 配置 MCP Server**

打开 Cursor 设置：`Cursor Settings` → `MCP Servers`

添加 Figma MCP 配置（通常 Cursor 已内置，只需启用）：

```json
{
  "mcpServers": {
    "cursor-browser-extension": {
      "command": "npx",
      "args": ["-y", "@cursor/mcp-browser-extension"]
    }
  }
}
```

**3. 验证配置**

配置完成后，你应该能在 Cursor 的 MCP 面板看到：
- ✅ Figma（显示绿点表示已连接）
- 12 tools, 1 prompts, 20 resources enabled

### 使用示例

当你告诉 AI "现在是 Figma 翻译阶段"并提供 Figma 链接时，AI 会自动：
1. 提取 Figma 设计稿信息
2. 分析组件、颜色、字体等设计规范
3. 输出结构化的设计文档

**Figma 链接格式：**
```
https://figma.com/design/:fileKey/:fileName?node-id=1-2
```

### 常见问题

**Q: 提示 Figma 连接失败？**  
A: 确保已安装 Cursor 浏览器扩展，并在 Figma 网页端登录。

**Q: 没有 Figma 设计稿怎么办？**  
A: 可以跳过 Figma 翻译阶段，直接从产品分析进入前端开发。

---

## 🎯 核心理念

将前端开发工作拆分为 **5 个独立的 AI 角色**，避免上下文污染：

```
0. 需求处理员（可选）    → 整理文档和图片
1. 产品分析师          → 分析需求，输出 PRD
1.5. Figma 翻译员      → 提取设计稿，输出设计规范
2. 前端开发            → 实现功能，写代码
3. 测试工程师          → 验证质量，输出测试报告
```

**关键原则**：

- ✅ **独立会话**：每个阶段新开窗口，告诉 Agent 当前阶段即可
- ✅ **文档交接**：通过文档传递信息，不口头传达
- ✅ **质量保障**：用户检查后手动提交，AI 不自动提交

---

## 📁 目录结构

```
specs/
├── README.md                        # 本文件
├── 新项目启动指引-含PDF.md            # ⭐ 推荐入口
├── roles/                           # 角色配置
│   ├── 0-requirement-processor/     # 需求处理员
│   ├── 1-analyst/                   # 产品分析师
│   ├── 1.5-figma-translator/        # Figma 翻译员
│   ├── 2-developer/                 # 前端开发
│   └── 3-tester/                    # 测试工程师
├── tasks/                           # 任务工作区
│   └── task-XXX/                    # 具体任务
│       ├── 0-input/                 # 输入（需求文档）
│       ├── 1-analysis/              # 分析产出（PRD）
│       ├── 1.5-design-spec/         # 设计规范（Figma 提取）
│       ├── 2-development/           # 开发产出（代码+文档）
│       └── 3-testing/               # 测试产出（测试报告）
├── converted/                       # 内部中转（角色自动生成，用户无需操作）
└── tools/                           # 内部工具（角色自动调用，用户无需操作）
    ├── task-init.sh                 # ⭐ 任务初始化脚本
    ├── doc-converter.py             # 文档转换工具
    └── start-auto-convert           # 自动监控转换
```

---

## 🔄 典型工作流

### 场景 1：有 Figma 设计稿 + 需求文档（完整流程）⭐

```bash
# 1. 初始化任务
./tools/task-init.sh 001 订单管理

# 2. 转换文档（如果有 PDF/Word）
python3 ./tools/doc-converter.py 需求文档.pdf
```

然后在不同阶段新开 Cursor 窗口：

```
阶段 0 (需求处理): 新开窗口 → 粘贴"新项目启动指引-含PDF.md" → 告诉 Agent "现在是需求处理阶段"
阶段 1 (产品分析): 新开窗口 → 粘贴"新项目启动指引-含PDF.md" → 告诉 Agent "现在是产品分析阶段"
阶段 1.5 (Figma 翻译): 新开窗口 → 粘贴"新项目启动指引-含PDF.md" → 告诉 Agent "现在是 Figma 翻译阶段" + 提供 Figma 链接
阶段 2 (前端开发): 新开窗口 → 粘贴"新项目启动指引-含PDF.md" → 告诉 Agent "现在是前端开发阶段"
阶段 3 (测试验证): 新开窗口 → 粘贴"新项目启动指引-含PDF.md" → 告诉 Agent "现在是测试验证阶段"
```

Agent 会自动根据当前阶段执行对应的逻辑。

**Figma 阶段示例对话：**
```
你：现在是 Figma 翻译阶段，这是设计稿链接：
https://figma.com/design/abc123/UserManagement?node-id=1-2

Agent：好的，我将提取 Figma 设计信息并输出设计规范文档...
```

最后检查代码，手动提交：

```bash
git add .
git commit -m "feat: [task-001] 实现订单管理功能"
```

### 场景 2：无设计稿，口头需求

```bash
# 初始化任务（跳过文档转换）
./tools/task-init.sh 002 数据导出
```

跳过需求处理和 Figma 翻译阶段：

```
阶段 1 (产品分析): 新开窗口 → 粘贴"新项目启动指引-含PDF.md" → 告诉 Agent "现在是产品分析阶段"
阶段 2 (前端开发): 新开窗口 → 粘贴"新项目启动指引-含PDF.md" → 告诉 Agent "现在是前端开发阶段"
阶段 3 (测试验证): 新开窗口 → 粘贴"新项目启动指引-含PDF.md" → 告诉 Agent "现在是测试验证阶段"
```

### 场景 3：只有 Figma 设计稿（UI 还原）

```bash
# 初始化任务
./tools/task-init.sh 003 登录页面
```

从 Figma 翻译开始：

```
阶段 1.5 (Figma 翻译): 新开窗口 → 提供 Figma 链接 → Agent 提取设计规范
阶段 2 (前端开发): 新开窗口 → Agent 根据设计规范实现 UI
阶段 3 (测试验证): 新开窗口 → 验证 UI 还原度
```

---

## 💡 推荐使用方式

### 分阶段新开窗口（推荐）⭐

每个阶段开一个新的 Cursor 窗口，确保上下文隔离：

```
1. 新开窗口 → 粘贴"新项目启动指引-含PDF.md" → 告诉 Agent 当前阶段
2. Agent 自动读取对应角色配置 (.cursorrules) 并处理
3. 完成后关闭窗口，进入下一阶段
```

**优点**：

- ✅ 自动化：Agent 自动识别阶段并执行对应逻辑
- ✅ 隔离性：每个阶段独立窗口，避免上下文污染
- ✅ 简单：只需粘贴同一个文件，无需手动切换配置

**示例对话**：

```
你：现在是产品分析阶段
（同时附上 @新项目启动指引-含PDF.md）

Agent：好的，我将以产品分析师的角色工作...
```

### 其他方式

如果你喜欢单窗口工作：

```
Cursor 窗口（项目根目录）
  ├── Chat 1: 粘贴"新项目启动指引-含PDF.md" + "产品分析阶段"
  ├── Chat 2: 粘贴"新项目启动指引-含PDF.md" + "前端开发阶段"
  └── Chat 3: 粘贴"新项目启动指引-含PDF.md" + "测试验证阶段"
```

---

## 🆘 常见问题

**Q: 简单需求需要走完整流程吗？**  
A: 灵活处理。改个样式直接改；小功能可以跳过需求处理员和 Figma 翻译；重要功能建议走完整流程。

**Q: 没有文档怎么办？**  
A: 跳过需求处理员，直接从产品分析师开始。

**Q: 没有 Figma 设计稿怎么办？**  
A: 跳过 Figma 翻译阶段，直接从产品分析进入前端开发。开发时可以参考现有组件库（Element Plus / Ant Design）。

**Q: 每次都要新开窗口吗？**  
A: 推荐每个阶段新开窗口，确保上下文隔离。只需粘贴同一个 `新项目启动指引-含PDF.md` 并告知阶段即可。

**Q: Figma MCP 配置失败怎么办？**  
A: 确保已安装 Cursor 浏览器扩展，并在 Figma 网页端登录。如果还是不行，可以手动查看 Figma 并描述给 AI。

**Q: AI 生成的代码不满意怎么办？**  
A: 明确告诉 AI 修改，或者自己改代码。AI 是辅助，你是主导。

---

## 🧹 任务清理

### 清空所有工作区内容

先进入 `specs` 目录：

```bash
cd /Users/zm00107ml/Desktop/specs
```

清除所有任务和转换文件（保留目录结构）：

```bash
rm -rf tasks/*(N) converted/*(N) roles/0-requirement-processor/converted/*(N)
```

> **说明**：`(N)` 是 zsh 的 glob 限定符，表示如果没有匹配项也不报错

### 归档任务（推荐）

如果想保留任务记录而非直接删除：

```bash
# 创建归档目录
mkdir -p archive/2025-Q1

# 移动已完成任务到归档
mv tasks/task-001-xxx archive/2025-Q1/

# 批量归档多个任务
mv tasks/task-00{1..5}-* archive/2025-Q1/
```

---

## 🚀 开始使用

1. ✅ 阅读完本文档（3 分钟）
2. ✅ 执行 `./tools/task-init.sh 001 测试功能`（1 分钟）
3. ✅ 新开窗口，粘贴 `@新项目启动指引-含PDF.md` + 告知阶段（10 分钟）
4. ✅ Agent 自动处理，完成后进入下一阶段

---

**让 AI 协作更清晰，开发质量更可控！** 🎯
