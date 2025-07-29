# buildsense-ai 团队工具自动安装脚本 (Windows)

$ORG_NAME = "buildsense-ai"
$TOOLS_DIR = "$env:USERPROFILE\.buildsense-tools"
$SCRIPT_URL = "https://github.com/$ORG_NAME/team-tools/raw/main/github-org-tools.ps1"

Write-Host "🚀 正在安装 buildsense-ai 团队工具..." -ForegroundColor Blue

# 创建工具目录
New-Item -ItemType Directory -Force -Path $TOOLS_DIR | Out-Null

# 下载脚本
Write-Host "📥 下载工具脚本..." -ForegroundColor Blue
try {
    Invoke-WebRequest -Uri $SCRIPT_URL -OutFile "$TOOLS_DIR\github-org-tools.ps1" -ErrorAction Stop
    $content = Get-Content "$TOOLS_DIR\github-org-tools.ps1" -Raw
    if ($content -match "<!DOCTYPE html>") {
        throw "Downloaded HTML instead of script"
    }
    Write-Host "✅ 从远程仓库下载成功" -ForegroundColor Green
} catch {
    Write-Host "⚠️  远程仓库不存在，使用本地文件" -ForegroundColor Yellow
    # 检查当前目录是否有脚本文件
    if (Test-Path ".\github-org-tools.ps1") {
        Copy-Item ".\github-org-tools.ps1" "$TOOLS_DIR\github-org-tools.ps1"
        Write-Host "✅ 复制本地脚本文件" -ForegroundColor Green
    } else {
        Write-Host "❌ 找不到脚本文件，请确保在正确的目录下运行安装脚本" -ForegroundColor Red
        exit 1
    }
}

# 检测 PowerShell 配置文件
$PROFILE_PATH = $PROFILE.CurrentUserAllHosts
if (-not (Test-Path $PROFILE_PATH)) {
    New-Item -ItemType File -Path $PROFILE_PATH -Force | Out-Null
}

# 检查是否已经安装过
$profileContent = Get-Content $PROFILE_PATH -ErrorAction SilentlyContinue
if ($profileContent -match "function org-create") {
    Write-Host "⚠️  工具已安装，正在更新..." -ForegroundColor Yellow
    # 删除旧的函数定义
    $profileContent = $profileContent | Where-Object { $_ -notmatch "function org-create|function org-check|function org-help" }
    $profileContent | Set-Content $PROFILE_PATH
}

# 添加函数到 PowerShell 配置
$functions = @"

# buildsense-ai 团队工具
function org-create {
    param([string]`$RepoName, [string]`$Visibility)
    & "$TOOLS_DIR\github-org-tools.ps1" create `$RepoName `$Visibility
}

function org-check {
    & "$TOOLS_DIR\github-org-tools.ps1" check
}

function org-help {
    & "$TOOLS_DIR\github-org-tools.ps1" help
}
"@

Add-Content -Path $PROFILE_PATH -Value $functions

Write-Host "✅ 安装完成！" -ForegroundColor Green
Write-Host "📝 已添加以下命令到 PowerShell 配置：" -ForegroundColor Blue
Write-Host "  org-create [仓库名] [可见性]  - 创建组织仓库" -ForegroundColor Gray
Write-Host "  org-check                      - 检查环境依赖" -ForegroundColor Gray
Write-Host "  org-help                       - 显示帮助" -ForegroundColor Gray

Write-Host "🔄 请重新加载 PowerShell 配置：" -ForegroundColor Yellow
Write-Host "  . `$PROFILE" -ForegroundColor Gray
Write-Host ""
Write-Host "🎉 之后就可以在任何项目目录下使用 org-create 命令了！" -ForegroundColor Green 