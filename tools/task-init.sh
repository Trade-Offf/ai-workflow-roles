#!/bin/bash

# AI多角色助手初始化工具
# 自动创建任务目录并生成所有AI角色的提示词
# 适用于任何功能开发

set -e

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 AI多角色助手初始化工具${NC}"
echo ""

# 获取任务编号和名称
if [ -z "$1" ]; then
    echo -e "${YELLOW}使用方法: $0 <任务编号> <功能名称>${NC}"
    echo ""
    echo "说明: 这是一个通用工具，可用于任何功能开发"
    echo ""
    echo "示例:"
    echo "  $0 001 用户登录"
    echo "  $0 002 订单管理"
    echo "  $0 003 数据导出"
    echo "  $0 004 权限配置"
    echo ""
    exit 1
fi

TASK_NUM=$1
TASK_NAME=$2

if [ -z "$TASK_NAME" ]; then
    TASK_NAME="新功能"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SPECS_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

TASK_DIR="task-${TASK_NUM}-${TASK_NAME}"
FULL_PATH="${SPECS_ROOT}/tasks/${TASK_DIR}"

# 检查是否已存在
if [ -d "$FULL_PATH" ]; then
    echo -e "${YELLOW}⚠️  任务目录已存在: ${FULL_PATH}${NC}"
    read -p "是否覆盖? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
    rm -rf "$FULL_PATH"
fi

# 创建目录结构
echo -e "${BLUE}📁 创建目录结构...${NC}"
mkdir -p "${FULL_PATH}/0-input/designs"
mkdir -p "${FULL_PATH}/0-input/original"
mkdir -p "${FULL_PATH}/1-analysis"
mkdir -p "${FULL_PATH}/1.5-design-spec"
mkdir -p "${FULL_PATH}/2-development"
mkdir -p "${FULL_PATH}/3-testing"

echo -e "${GREEN}✅ 目录创建成功: ${FULL_PATH}${NC}"
echo ""

# 生成提示词文件
PROMPTS_FILE="${FULL_PATH}/PROMPTS.md"

cat > "$PROMPTS_FILE" << EOF
# ${TASK_NAME} - 提示词清单

> 任务编号: task-${TASK_NUM}
> 创建时间: $(date +"%Y-%m-%d %H:%M:%S")

---

## 📝 使用说明

在Cursor中为每个角色创建一个新Chat，复制对应的提示词。

**快捷键**: 在Cursor中按 \`Cmd/Ctrl + Shift + L\` 打开新Chat

---

## 🎯 Chat 0: 需求处理员（可选）

**适用场景**: 有Word/PDF文档需要转换

\`\`\`
你是需求处理员，请遵守以下规则：
@roles/0-requirement-processor/.cursorrules

我有一份转换后的需求文档需要整理。

[粘贴转换后的文档内容]

请执行以下任务：
1. 重新组织结构（按功能模块，不按页面）
2. 定位图片到正确位置
3. 添加详细的图片说明（布局、元素、交互）
4. 提取关键需求和约束条件
5. 标注待澄清的问题

输出文件：
- tasks/${TASK_DIR}/0-input/REQUIREMENT_INPUT.md

复制图片到：
- tasks/${TASK_DIR}/0-input/designs/
\`\`\`

---

## 🎯 Chat 1: 产品分析师

\`\`\`
你是产品分析师，请遵守以下规则：
@roles/1-analyst/.cursorrules

请分析以下需求并输出完整的PRD文档：

需求输入文档：
@tasks/${TASK_DIR}/0-input/REQUIREMENT_INPUT.md

项目信息：
- 项目名称：management-platform
- 子应用：ls-cms（或 operation-platform / cashinout / main）
- 技术栈：Vue 3 + Element Plus（或 React + Ant Design）

输出内容：
1. 需求背景和目标
2. 功能详细设计
3. 交互流程
4. 数据字段定义
5. 技术约束和边界
6. 验收标准

输出文件：
- tasks/${TASK_DIR}/1-analysis/PRD.md
- tasks/${TASK_DIR}/1-analysis/HANDOFF_TO_DEV.md
\`\`\`

---

## 🎯 Chat 1.5: Figma 翻译员（可选）

**适用场景**: 有Figma设计稿需要提取设计规范

\`\`\`
你是Figma翻译员，请遵守以下规则：
@roles/1.5-figma-translator/.cursorrules

请从Figma设计稿中提取设计规范：

PRD文档：
@tasks/${TASK_DIR}/1-analysis/PRD.md

Figma链接：
[用户提供的Figma设计稿链接]

任务：
1. 使用MCP工具读取Figma设计信息
2. 提取设计令牌（颜色、字体、间距、圆角等）
3. 分析组件规范（按钮、输入框、表格等）
4. 整理页面布局和交互状态
5. 输出结构化的设计规范文档

输出文件：
- tasks/${TASK_DIR}/1.5-design-spec/DESIGN_SPEC.md
- tasks/${TASK_DIR}/1.5-design-spec/HANDOFF_TO_DEV.md

注意：
- 确保Cursor已配置Figma MCP Server
- 提供完整的Figma链接（包含node-id）
- 如果没有Figma设计稿，可以跳过此阶段
\`\`\`

---

## 🎯 Chat 2: 前端开发

\`\`\`
你是前端开发工程师，请遵守以下规则：
@roles/2-developer/.cursorrules

请根据PRD和设计规范开发功能：

PRD文档：
@tasks/${TASK_DIR}/1-analysis/PRD.md

设计规范（如果有Figma设计稿）：
@tasks/${TASK_DIR}/1.5-design-spec/DESIGN_SPEC.md

项目信息：
- 子应用：ls-cms（或 operation-platform / cashinout / main）
- 技术栈：Vue 3 + Element Plus（或 React 17 + Ant Design）
- 目标目录：apps/ls-cms/src/views/[功能模块]/

开发要求：
1. 创建组件文件
2. 实现业务逻辑
3. 根据设计规范添加样式（如果有）
4. 遵循项目代码规范
5. 输出开发文档

输出文件：
- tasks/${TASK_DIR}/2-development/DEV_DOC.md
- tasks/${TASK_DIR}/2-development/HANDOFF_TO_QA.md
\`\`\`

---

## 🎯 Chat 3: 测试工程师

\`\`\`
你是测试工程师，请遵守以下规则：
@roles/3-tester/.cursorrules

请根据开发文档生成完整的测试用例：

开发文档：
@tasks/${TASK_DIR}/2-development/DEV_DOC.md

测试要求：
1. 功能测试用例
2. 边界测试用例
3. 交互测试用例
4. 兼容性测试
5. 性能测试（如需要）

输出文件：
- tasks/${TASK_DIR}/3-testing/TEST_CASES.md
- tasks/${TASK_DIR}/3-testing/TEST_REPORT.md
\`\`\`

---

## 🔄 文档转换（如需要）

如果有Word/PDF文档需要转换：

\`\`\`bash
# 方式1: 自动转换（推荐）
${SPECS_ROOT}/tools/start-auto-convert  # 新终端，持续运行
cp ~/Desktop/需求.pdf ${SPECS_ROOT}/roles/0-requirement-processor/

# 方式2: 手动转换
python3 ${SPECS_ROOT}/tools/doc-converter.py ~/Desktop/需求.pdf
cat ${SPECS_ROOT}/roles/0-requirement-processor/converted/需求.md | pbcopy
\`\`\`

---

## 📋 快速检查清单

- [ ] 需求处理（如有文档）
- [ ] 产品分析完成
- [ ] Figma设计规范提取（如有设计稿）
- [ ] 开发实现完成
- [ ] 测试验证完成
- [ ] 代码已提交

---

## 📞 更多帮助

- 快速操作卡: specs/快速操作卡.md
- 提示词模板: specs/提示词模板.md
- 完整SOP: specs/新需求标准操作流程_SOP.md

EOF

echo -e "${GREEN}✅ 提示词文件已生成: ${PROMPTS_FILE}${NC}"
echo ""

# 显示下一步操作
echo -e "${BLUE}🎯 下一步操作:${NC}"
echo ""
echo -e "1. ${YELLOW}在Cursor中打开提示词文件:${NC}"
echo "   open ${PROMPTS_FILE}"
echo ""
echo -e "2. ${YELLOW}为每个AI角色创建一个新Chat（Cmd/Ctrl + Shift + L）${NC}"
echo "   - Chat 0: 需求处理员（可选，仅当有.docx/.pdf文档时）"
echo "   - Chat 1: 产品分析师"
echo "   - Chat 1.5: Figma翻译员（可选，仅当有Figma设计稿时）"
echo "   - Chat 2: 前端开发"
echo "   - Chat 3: 测试工程师"
echo ""
echo -e "3. ${YELLOW}从PROMPTS.md复制对应的提示词到每个Chat${NC}"
echo ""
echo -e "4. ${YELLOW}如果有Word/PDF文档需要转换:${NC}"
echo "   python3 specs/tools/doc-converter.py 文档路径"
echo "   然后将结果粘贴给需求处理员（Chat 0）"
echo ""
echo -e "${GREEN}🎉 AI多角色助手准备完成！开始开发 ${TASK_NAME} 吧！${NC}"
echo ""

# 自动打开提示词文件
if command -v open &> /dev/null; then
    open "$PROMPTS_FILE"
elif command -v xdg-open &> /dev/null; then
    xdg-open "$PROMPTS_FILE"
fi

