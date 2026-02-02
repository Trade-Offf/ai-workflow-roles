# 新项目启动指引（含PDF）

> 目标：最少理解、最少操作，直接跑通 4 个角色的流程。

---

## 最短步骤（推荐）

```
./tools/task-init.sh 001 功能名称
python3 tools/doc-converter.py "/path/to/需求.pdf"
open tasks/task-001-功能名称/PROMPTS.md
```

**说明**

- `task-init.sh` 可在任意目录运行，脚本会自动定位 `specs` 根目录。
- 转换结果会生成在 `converted/<文档名>.md`。
- 打开 `PROMPTS.md` 后，按里面的提示创建 Chat 并粘贴对应提示词即可。

---

## PDF 相关分支

### 有 PDF

把 `converted/<文档名>.md` 内容粘贴给 **Chat 0（需求处理员）**，让它输出结构化需求文档。

### 没有 PDF / 需求很小

跳过 Chat 0，直接把需求给 **Chat 1（产品分析师）**。

### PDF 已经转换过

直接用现成的 `.md`，不需要再执行转换命令。

---

## 常见问题

**Q: 找不到 PROMPTS.md？**  
A: 请检查 `tasks/task-001-功能名称/` 是否生成成功。
