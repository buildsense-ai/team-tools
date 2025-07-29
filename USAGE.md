# buildsense-ai 团队工具使用指南

## 🚀 一键安装

### 1. 安装 GitHub CLI

**macOS:**
```bash
brew install gh
```

**Windows:**
```powershell
winget install GitHub.cli
```

### 2. 认证 GitHub CLI

```bash
gh auth login
```

选择：`GitHub.com` → `HTTPS` → `Yes` → `Login with a web browser`

### 3. 安装团队工具

#### macOS/Linux
```bash
curl -L https://github.com/buildsense-ai/team-tools/raw/main/install-org-tools.sh -o install-org-tools.sh
chmod +x install-org-tools.sh
./install-org-tools.sh
source ~/.zshrc  # 或 source ~/.bashrc
```

#### Windows
```powershell
Invoke-WebRequest -Uri "https://github.com/buildsense-ai/team-tools/raw/main/install-org-tools.ps1" -OutFile "install-org-tools.ps1"
.\install-org-tools.ps1
. $PROFILE
```

## 📝 日常使用

```bash
# 1. 创建新项目
mkdir my-project && cd my-project
git init
echo "# My Project" > README.md
git add . && git commit -m "Initial commit"

# 2. 一键创建组织仓库
org-create

# 3. 正常开发
git add . && git commit -m "updates"
git push
```

## 🔧 可用命令

- `org-create [仓库名] [可见性]` - 创建组织仓库
- `org-check` - 检查环境依赖
- `org-help` - 显示帮助

## 🎯 优势

- ✅ 一次安装，永久使用
- ✅ 命令简洁：`org-create` 替代复杂命令
- ✅ 自动更新到最新版本
- ✅ 跨平台支持
- ✅ 团队统一配置

## ❓ 常见问题

**Q: 需要什么权限？**
A: 需要在组织中有创建仓库的权限。

**Q: Push 时提示认证失败？**
A: 脚本会自动配置认证，如果失败请运行：`git config --global credential.helper 'gh auth git-credential'` 