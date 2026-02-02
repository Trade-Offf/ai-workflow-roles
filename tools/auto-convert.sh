#!/bin/bash
# 自动文档转换脚本
# 监控 0-requirement-processor 目录，自动转换 .docx 和 .pdf 文件

# 配置
WATCH_DIR="/Users/zm00107ml/Desktop/management-platform/specs/roles/0-requirement-processor"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONVERTER="$SCRIPT_DIR/doc-converter.py"

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}📂 自动文档转换器已启动${NC}"
echo -e "${YELLOW}监控目录: $WATCH_DIR${NC}"
echo -e "${YELLOW}支持格式: .docx, .pdf${NC}"
echo ""
echo "💡 使用方法："
echo "   1. 将 .docx 或 .pdf 文件放到需求处理员目录"
echo "   2. 脚本会自动转换"
echo "   3. 转换结果会自动复制到剪贴板"
echo ""
echo "按 Ctrl+C 停止监控"
echo "----------------------------------------"

# 检查依赖
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ 未找到 python3${NC}"
    exit 1
fi

if ! python3 -c "import docx" 2>/dev/null; then
    echo -e "${YELLOW}⚠️  缺少 python-docx，正在安装...${NC}"
    pip3 install python-docx PyPDF2
fi

# 转换函数
convert_file() {
    local file="$1"
    local filename=$(basename "$file")
    
    echo -e "${GREEN}🔄 发现新文件: $filename${NC}"
    
    # 检查是否是支持的格式
    if [[ ! "$file" =~ \.(docx|pdf)$ ]]; then
        return
    fi
    
    # 转换
    echo "📝 正在转换..."
    python3 "$CONVERTER" "$file"
    
    if [ $? -eq 0 ]; then
        # 获取转换后的文件
        local base="${filename%.*}"
        local converted_file="$(dirname "$file")/converted/${base}.md"
        
        if [ -f "$converted_file" ]; then
            # 复制到剪贴板（macOS）
            cat "$converted_file" | pbcopy
            
            echo -e "${GREEN}✅ 转换完成！${NC}"
            echo -e "${GREEN}📋 内容已复制到剪贴板${NC}"
            echo -e "${YELLOW}💡 现在可以在需求处理员会话中粘贴 (Command+V)${NC}"
            echo ""
            
            # 显示文件位置
            echo "📁 输出文件:"
            echo "   Markdown: $converted_file"
            
            if [ -d "$(dirname "$file")/converted/designs" ]; then
                local img_count=$(ls "$(dirname "$file")/converted/designs" 2>/dev/null | wc -l)
                if [ $img_count -gt 0 ]; then
                    echo "   图片目录: $(dirname "$file")/converted/designs/ (共 $img_count 张)"
                fi
            fi
            
            echo "----------------------------------------"
        fi
    else
        echo -e "${RED}❌ 转换失败${NC}"
    fi
}

# 检查目录是否存在
if [ ! -d "$WATCH_DIR" ]; then
    echo -e "${RED}❌ 目录不存在: $WATCH_DIR${NC}"
    exit 1
fi

# macOS 使用 fswatch
if command -v fswatch &> /dev/null; then
    echo -e "${GREEN}使用 fswatch 监控（实时）${NC}"
    echo ""
    
    fswatch -0 "$WATCH_DIR" | while read -d "" event; do
        if [[ "$event" =~ \.(docx|pdf)$ ]] && [ -f "$event" ]; then
            convert_file "$event"
        fi
    done
else
    echo -e "${YELLOW}⚠️  未安装 fswatch，使用轮询模式（每5秒检查一次）${NC}"
    echo -e "${YELLOW}建议安装 fswatch: brew install fswatch${NC}"
    echo ""
    
    # 记录已处理的文件
    PROCESSED_FILE="/tmp/doc-converter-processed.txt"
    touch "$PROCESSED_FILE"
    
    while true; do
        # 查找新文件
        find "$WATCH_DIR" -maxdepth 1 -type f \( -name "*.docx" -o -name "*.pdf" \) | while read file; do
            # 检查是否已处理
            if ! grep -q "$file" "$PROCESSED_FILE"; then
                convert_file "$file"
                echo "$file" >> "$PROCESSED_FILE"
            fi
        done
        
        sleep 5
    done
fi



