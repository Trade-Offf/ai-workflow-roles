#!/usr/bin/env python3
"""
高级文档转换工具 - 支持 PDF 图片提取
将 .docx 和 .pdf 文件转换为 Markdown 格式，提取图片
"""

import sys
import os
from pathlib import Path

def convert_pdf_with_images(input_file, output_dir):
    """使用 PyMuPDF 转换 PDF 并提取图片"""
    try:
        import fitz  # PyMuPDF
        from PIL import Image
        import io
        
        doc = fitz.open(input_file)
        output = []
        image_count = 0
        images_dir = Path(output_dir) / "designs"
        images_dir.mkdir(parents=True, exist_ok=True)
        
        output.append(f"# PDF文档转换\n")
        output.append(f"来源: {Path(input_file).name}\n")
        output.append(f"页数: {len(doc)}\n\n")
        
        for page_num in range(len(doc)):
            page = doc[page_num]
            
            # 提取文本
            text = page.get_text()
            
            # 提取图片
            image_list = page.get_images()
            
            if text.strip():
                output.append(f"## 第 {page_num + 1} 页\n")
                output.append(text + "\n")
            
            # 在文本后插入该页的所有图片
            if image_list:
                output.append(f"\n### 📸 第 {page_num + 1} 页的图片\n")
                
                for img_index, img in enumerate(image_list):
                    try:
                        xref = img[0]
                        base_image = doc.extract_image(xref)
                        image_bytes = base_image["image"]
                        image_ext = base_image["ext"]
                        
                        image_count += 1
                        image_filename = f"第{page_num + 1}页_图片{img_index + 1}.{image_ext}"
                        image_path = images_dir / image_filename
                        
                        # 保存图片
                        with open(image_path, "wb") as img_file:
                            img_file.write(image_bytes)
                        
                        # 在文档中插入图片引用（带更多上下文信息）
                        output.append(f"\n![{image_filename}](./designs/{image_filename})\n")
                        output.append(f"**图片 {image_count}**: `{image_filename}`\n")
                        output.append(f"- 位置：第 {page_num + 1} 页\n")
                        output.append(f"- ⚠️ **需要重新定位**：请根据上方文本内容，将此图片移动到相关描述附近\n\n")
                        
                    except Exception as e:
                        print(f"⚠️  提取图片失败 (页 {page_num + 1}, 图 {img_index + 1}): {e}")
                
                output.append("\n---\n")
        
        doc.close()
        return "\n".join(output), image_count
    
    except ImportError:
        print("❌ 缺少高级依赖包")
        print("请安装: pip3 install -r requirements-advanced.txt")
        print("或: pip3 install pymupdf pillow")
        return None, 0
    except Exception as e:
        print(f"❌ PDF转换失败: {e}")
        return None, 0


def convert_docx(input_file, output_dir):
    """转换 Word 文档为 Markdown"""
    try:
        from docx import Document
        from docx.oxml.text.paragraph import CT_P
        from docx.oxml.table import CT_Tbl
        from docx.table import Table
        from docx.text.paragraph import Paragraph
        
        doc = Document(input_file)
        output = []
        image_count = 0
        images_dir = Path(output_dir) / "designs"
        images_dir.mkdir(parents=True, exist_ok=True)
        
        # 提取文本和表格
        for element in doc.element.body:
            if isinstance(element, CT_P):
                para = Paragraph(element, doc)
                text = para.text.strip()
                if text:
                    if para.style.name.startswith('Heading'):
                        level = para.style.name[-1]
                        if level.isdigit():
                            output.append(f"\n{'#' * int(level)} {text}\n")
                        else:
                            output.append(f"\n## {text}\n")
                    else:
                        output.append(text + "\n")
            
            elif isinstance(element, CT_Tbl):
                table = Table(element, doc)
                output.append("\n")
                
                for i, row in enumerate(table.rows):
                    cells = [cell.text.strip() for cell in row.cells]
                    output.append("| " + " | ".join(cells) + " |")
                    if i == 0:
                        output.append("| " + " | ".join(["---"] * len(cells)) + " |")
                
                output.append("\n")
        
        # 提取图片
        for rel in doc.part.rels.values():
            if "image" in rel.target_ref:
                image_count += 1
                image_data = rel.target_part.blob
                ext = rel.target_ref.split('.')[-1]
                image_filename = f"图片{image_count}.{ext}"
                image_path = images_dir / image_filename
                
                with open(image_path, 'wb') as f:
                    f.write(image_data)
                
                output.append(f"\n![{image_filename}](./designs/{image_filename})\n")
        
        return "\n".join(output), image_count
    
    except ImportError:
        print("❌ 缺少依赖包，请安装：pip3 install python-docx")
        return None, 0
    except Exception as e:
        print(f"❌ 转换失败: {e}")
        return None, 0


def main():
    if len(sys.argv) < 2:
        print("高级文档转换工具 (支持 PDF 图片提取)")
        print("\n使用方法: python3 doc-converter-advanced.py <文件路径>")
        print("\n支持格式: .docx, .pdf")
        print("\n示例:")
        print("  python3 doc-converter-advanced.py 需求文档.docx")
        print("  python3 doc-converter-advanced.py 需求文档.pdf  # 会提取图片")
        sys.exit(1)
    
    input_file = sys.argv[1]
    input_path = Path(input_file)
    
    if not input_path.exists():
        print(f"❌ 文件不存在: {input_file}")
        sys.exit(1)
    
    output_dir = input_path.parent / "converted"
    output_dir.mkdir(exist_ok=True)
    output_file = output_dir / f"{input_path.stem}.md"
    
    print(f"📄 正在转换: {input_file}")
    print(f"📁 输出目录: {output_dir}")
    
    content = None
    image_count = 0
    
    if input_path.suffix.lower() == '.docx':
        print("📝 转换 Word 文档...")
        content, image_count = convert_docx(input_file, output_dir)
    
    elif input_path.suffix.lower() == '.pdf':
        print("📕 转换 PDF 文档（包含图片提取）...")
        content, image_count = convert_pdf_with_images(input_file, output_dir)
    
    else:
        print(f"❌ 不支持的格式: {input_path.suffix}")
        sys.exit(1)
    
    if content:
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(content)
        
        print(f"\n✅ 转换成功!")
        print(f"📄 Markdown 文件: {output_file}")
        if image_count > 0:
            print(f"🖼️  提取图片数量: {image_count}")
            print(f"📁 图片目录: {output_dir}/designs/")
        else:
            print("⚠️  未发现图片")
        
        print(f"\n💡 下一步:")
        print(f"   复制内容给需求处理员:")
        print(f"   cat '{output_file}' | pbcopy")
    else:
        print("❌ 转换失败")
        sys.exit(1)


if __name__ == "__main__":
    main()

