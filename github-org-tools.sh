#!/bin/bash

# GitHub 组织工具集
# 适用于 buildsense-ai 团队
# 支持 macOS, Linux, Windows (Git Bash)

# 配置区域 - 团队成员可以修改这里
ORG_NAME="buildsense-ai"
DEFAULT_VISIBILITY="public"  # 或 "private"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 检查依赖
check_dependencies() {
    if ! command -v gh &> /dev/null; then
        echo -e "${RED}❌ GitHub CLI (gh) 未安装${NC}"
        echo "请安装 GitHub CLI: https://cli.github.com/"
        return 1
    fi

    if ! command -v git &> /dev/null; then
        echo -e "${RED}❌ Git 未安装${NC}"
        return 1
    fi

    # 检查 GitHub CLI 认证
    if ! gh auth status &> /dev/null; then
        echo -e "${RED}❌ GitHub CLI 未认证${NC}"
        echo "请运行: gh auth login"
        return 1
    fi

    return 0
}

# 创建组织仓库
create_org_repo() {
    local repo_name="$1"
    local visibility="$2"
    
    # 如果没有提供仓库名，使用当前目录名
    if [ -z "$repo_name" ]; then
        repo_name=$(basename "$PWD")
    fi
    
    # 如果没有指定可见性，使用默认值
    if [ -z "$visibility" ]; then
        visibility="$DEFAULT_VISIBILITY"
    fi

    echo -e "${BLUE}🚀 准备在组织 $ORG_NAME 下创建仓库: $repo_name${NC}"

    # 检查是否在 git 仓库中
    if [ ! -d ".git" ]; then
        echo -e "${RED}❌ 错误：当前目录不是一个 git 仓库${NC}"
        echo "请先运行: git init"
        return 1
    fi

    # 检查是否有提交
    if [ -z "$(git log --oneline 2>/dev/null)" ]; then
        echo -e "${RED}❌ 错误：仓库中没有任何提交${NC}"
        echo "请先添加文件并提交：git add . && git commit -m 'Initial commit'"
        return 1
    fi

    # 检查是否已经有 remote origin
    if git remote get-url origin >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  警告：已经存在 remote origin：${NC}"
        git remote get-url origin
        echo -n "是否要替换现有的 remote origin? (y/N): "
        read -r confirm
        if [[ $confirm =~ ^[Yy]$ ]]; then
            git remote remove origin
            echo -e "${GREEN}✅ 已删除现有的 remote origin${NC}"
        else
            echo -e "${RED}❌ 操作已取消${NC}"
            return 1
        fi
    fi

    echo -e "${BLUE}📦 正在组织 $ORG_NAME 下创建仓库 $repo_name...${NC}"

    # 创建组织仓库
    if [ "$visibility" = "private" ]; then
        gh repo create "$ORG_NAME/$repo_name" --private --clone=false
    else
        gh repo create "$ORG_NAME/$repo_name" --public --clone=false
    fi

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ 仓库创建成功！${NC}"
        
        # 添加 remote origin
        git remote add origin "https://github.com/$ORG_NAME/$repo_name.git"
        echo -e "${GREEN}✅ 已添加 remote origin${NC}"
        
        # 配置 Git 使用 GitHub CLI 认证
        git config credential.helper 'gh auth git-credential' 2>/dev/null || true
        echo -e "${GREEN}✅ 已配置 Git 认证${NC}"
        
        # 设置默认分支为 main（如果当前不是）
        local current_branch=$(git branch --show-current)
        if [ "$current_branch" != "main" ]; then
            git branch -M main
            echo -e "${GREEN}✅ 已将分支重命名为 main${NC}"
        fi
        
        # Push 到远程仓库
        echo -e "${BLUE}📤 正在 push 到远程仓库...${NC}"
        git push -u origin main
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}🎉 成功！仓库已创建并代码已推送！${NC}"
            echo -e "${BLUE}🔗 仓库地址: https://github.com/$ORG_NAME/$repo_name${NC}"
        else
            echo -e "${RED}❌ Push 失败，请检查网络连接或权限${NC}"
            return 1
        fi
    else
        echo -e "${RED}❌ 仓库创建失败，请检查：${NC}"
        echo "   1. 你是否有在组织 $ORG_NAME 下创建仓库的权限"
        echo "   2. 仓库名 $repo_name 是否已经存在"
        echo "   3. GitHub CLI 是否正确认证"
        return 1
    fi
}

# 显示帮助
show_help() {
    echo "GitHub 组织工具集 - buildsense-ai 团队"
    echo ""
    echo "使用方法:"
    echo "  $0 create [仓库名] [可见性]   - 创建组织仓库并推送"
    echo "  $0 check                      - 检查环境依赖"
    echo "  $0 help                       - 显示此帮助"
    echo ""
    echo "参数说明:"
    echo "  仓库名    可选，默认使用当前目录名"
    echo "  可见性    可选，public 或 private，默认为 $DEFAULT_VISIBILITY"
    echo ""
    echo "示例:"
    echo "  $0 create                     # 使用当前目录名创建公开仓库"
    echo "  $0 create my-project          # 创建名为 my-project 的仓库"
    echo "  $0 create my-project private  # 创建私有仓库"
}

# 主函数
main() {
    case "${1:-help}" in
        "create")
            if ! check_dependencies; then
                exit 1
            fi
            create_org_repo "$2" "$3"
            ;;
        "check")
            check_dependencies
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}✅ 所有依赖都已安装并配置正确${NC}"
            fi
            ;;
        "help"|"--help"|"-h"|"")
            show_help
            ;;
        *)
            echo -e "${RED}❌ 未知命令: $1${NC}"
            show_help
            exit 1
            ;;
    esac
}

# 运行主函数
main "$@" 