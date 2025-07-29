# buildsense-ai 团队工具集

🚀 一键安装和使用团队开发工具

## 📋 功能特性

- ✅ 自动在 `buildsense-ai` 组织下创建仓库
- ✅ 自动设置 remote origin 并推送代码
- ✅ 支持公开/私有仓库选择
- ✅ 跨平台支持（macOS, Linux, Windows）
- ✅ 一键安装，永久使用
- ✅ 简洁的命令别名

## 🚀 快速开始

### 新团队成员设置（一次性）

#### macOS / Linux

```bash
# 下载并运行安装脚本
curl -L https://github.com/buildsense-ai/team-tools/raw/main/install-org-tools.sh -o install-org-tools.sh
chmod +x install-org-tools.sh
./install-org-tools.sh

# 重新加载配置
source ~/.zshrc  # 或 source ~/.bashrc
```

#### Windows

```powershell
# 下载并运行安装脚本
Invoke-WebRequest -Uri "https://github.com/buildsense-ai/team-tools/raw/main/install-org-tools.ps1" -OutFile "install-org-tools.ps1"
.\install-org-tools.ps1

# 重新加载配置
. $PROFILE
```

### 日常使用（超简单）

```bash
# 创建新项目
mkdir my-new-project && cd my-new-project
git init
echo "# My Project" > README.md
git add . && git commit -m "Initial commit"

# 一键创建组织仓库
org-create

# 或者指定名称和可见性
org-create my-project private
```

## 📝 完整工作流程

```bash
# 1. 创建新项目
mkdir my-project && cd my-project
git init
echo "# My Project" > README.md
git add . && git commit -m "Initial commit"

# 2. 一键推送到组织
org-create

# 3. 之后的正常工作
git add . && git commit -m "updates"
git push
```

## 🔧 支持的命令

安装后，你可以在任何项目目录下使用以下命令：

- `org-create [仓库名] [可见性]` - 创建组织仓库
- `org-check` - 检查环境依赖
- `org-help` - 显示帮助

### 命令示例

```bash
# 使用当前目录名创建公开仓库
org-create

# 创建指定名称的公开仓库
org-create my-project

# 创建私有仓库
org-create my-project private

# 检查环境配置
org-check

# 显示帮助信息
org-help
```

## 🔧 团队配置

如果需要修改组织名称，编辑安装的脚本文件：

```bash
# macOS/Linux
nano ~/.buildsense-tools/github-org-tools.sh

# Windows
notepad $env:USERPROFILE\.buildsense-tools\github-org-tools.ps1
```

修改第一行的 `ORG_NAME="buildsense-ai"` 为你的组织名。

## ❓ 常见问题

**Q: 需要什么权限？**
A: 需要在组织中有创建仓库的权限。

**Q: Push 时提示认证失败？**
A: 脚本会自动配置认证，如果失败请运行：`git config --global credential.helper 'gh auth git-credential'`

**Q: 如何卸载工具？**
A: 删除 `~/.buildsense-tools` 目录，并从 shell 配置文件中删除相关别名/函数。

**Q: 如何更新工具？**
A: 重新运行安装脚本即可自动更新到最新版本。

## 🛠️ 手动安装（高级用户）

如果你不想使用自动安装脚本，也可以手动安装：

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

### 3. 下载脚本

- `github-org-tools.sh` (macOS/Linux)
- `github-org-tools.ps1` (Windows)

### 4. 手动设置别名

**macOS/Linux (.zshrc 或 .bashrc):**
```bash
alias org-create='./github-org-tools.sh create'
alias org-check='./github-org-tools.sh check'
alias org-help='./github-org-tools.sh help'
```

**Windows PowerShell ($PROFILE):**
```powershell
function org-create { param([string]$RepoName, [string]$Visibility) .\github-org-tools.ps1 create $RepoName $Visibility }
function org-check { .\github-org-tools.ps1 check }
function org-help { .\github-org-tools.ps1 help }
```

## 🎯 优势

1. **一次安装，永久使用** - 新电脑只需要运行一次安装脚本
2. **命令简洁** - `org-create` 比 `./github-org-tools.sh create` 简单多了
3. **自动更新** - 每次运行安装脚本会自动更新到最新版本
4. **跨平台** - 支持 macOS/Linux 和 Windows
5. **团队统一** - 所有成员使用相同的命令和配置
6. **零配置** - 自动检测 shell 类型并配置别名
