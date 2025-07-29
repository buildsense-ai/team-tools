#!/bin/bash

# buildsense-ai 团队工具自动安装脚本
# 支持 macOS, Linux, Windows (Git Bash)

# 配置
ORG_NAME="buildsense-ai"
TOOLS_DIR="$HOME/.buildsense-tools"
SCRIPT_URL="https://github.com/$ORG_NAME/team-tools/raw/main/github-org-tools.sh"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 正在安装 buildsense-ai 团队工具...${NC}"

# 创建工具目录
mkdir -p "$TOOLS_DIR"

# 下载脚本
echo -e "${BLUE}📥 下载工具脚本...${NC}"
if curl -L "$SCRIPT_URL" -o "$TOOLS_DIR/github-org-tools.sh" 2>/dev/null && [ -s "$TOOLS_DIR/github-org-tools.sh" ] && ! grep -q "<!DOCTYPE html>" "$TOOLS_DIR/github-org-tools.sh"; then
    echo -e "${GREEN}✅ 从远程仓库下载成功${NC}"
else
    echo -e "${YELLOW}⚠️  远程仓库不存在，使用本地文件${NC}"
    # 检查当前目录是否有脚本文件
    if [ -f "./github-org-tools.sh" ]; then
        cp "./github-org-tools.sh" "$TOOLS_DIR/github-org-tools.sh"
        echo -e "${GREEN}✅ 复制本地脚本文件${NC}"
    else
        echo -e "${RED}❌ 找不到脚本文件，请确保在正确的目录下运行安装脚本${NC}"
        exit 1
    fi
fi
chmod +x "$TOOLS_DIR/github-org-tools.sh"

# 检测 shell 类型
SHELL_CONFIG=""
if [[ "$SHELL" == *"zsh"* ]]; then
    SHELL_CONFIG="$HOME/.zshrc"
elif [[ "$SHELL" == *"bash"* ]]; then
    SHELL_CONFIG="$HOME/.bashrc"
else
    echo -e "${YELLOW}⚠️  无法检测 shell 类型，请手动添加别名${NC}"
    echo "请将以下行添加到你的 shell 配置文件中："
    echo "alias org-create='$TOOLS_DIR/github-org-tools.sh create'"
    exit 1
fi

# 检查是否已经安装过
if grep -q "alias org-create" "$SHELL_CONFIG" 2>/dev/null; then
    echo -e "${YELLOW}⚠️  工具已安装，正在更新...${NC}"
    # 删除旧的别名行
    sed -i.bak '/alias org-create=/d' "$SHELL_CONFIG"
fi

# 添加别名到 shell 配置
echo "" >> "$SHELL_CONFIG"
echo "# buildsense-ai 团队工具" >> "$SHELL_CONFIG"
echo "alias org-create='$TOOLS_DIR/github-org-tools.sh create'" >> "$SHELL_CONFIG"
echo "alias org-check='$TOOLS_DIR/github-org-tools.sh check'" >> "$SHELL_CONFIG"
echo "alias org-help='$TOOLS_DIR/github-org-tools.sh help'" >> "$SHELL_CONFIG"

echo -e "${GREEN}✅ 安装完成！${NC}"
echo -e "${BLUE}📝 已添加以下命令到 $SHELL_CONFIG：${NC}"
echo "  org-create [仓库名] [可见性]  - 创建组织仓库"
echo "  org-check                      - 检查环境依赖"
echo "  org-help                       - 显示帮助"

echo -e "${YELLOW}🔄 请重新加载 shell 配置或重启终端：${NC}"
echo "  source $SHELL_CONFIG"
echo ""
echo -e "${GREEN}🎉 之后就可以在任何项目目录下使用 org-create 命令了！${NC}" 