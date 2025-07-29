# buildsense-ai 团队工具自动安装脚本 (Windows)

$ORG_NAME = "buildsense-ai"
$TOOLS_DIR = "$env:USERPROFILE\.buildsense-tools"
$SCRIPT_URL = "https://github.com/$ORG_NAME/team-tools/raw/main/github-org-tools.ps1"

Write-Host "🚀 正在安装 buildsense-ai 团队工具..." -ForegroundColor Blue

# 创建工具目录
New-Item -ItemType Directory -Force -Path $TOOLS_DIR | Out-Null

# 下载脚本
Write-Host "📥 检查脚本文件..." -ForegroundColor Blue
# 优先使用本地文件
if (Test-Path ".\github-org-tools.ps1") {
    Copy-Item ".\github-org-tools.ps1" "$TOOLS_DIR\github-org-tools.ps1"
    Write-Host "✅ 使用本地脚本文件" -ForegroundColor Green
} else {
    Write-Host "⚠️  本地文件不存在，尝试从远程下载" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri $SCRIPT_URL -OutFile "$TOOLS_DIR\github-org-tools.ps1" -ErrorAction Stop
        $content = Get-Content "$TOOLS_DIR\github-org-tools.ps1" -Raw
        if ($content -match "<!DOCTYPE html>") {
            throw "Downloaded HTML instead of script"
        }
        Write-Host "✅ 从远程仓库下载成功" -ForegroundColor Green
    } catch {
        Write-Host "❌ 找不到脚本文件，请确保在正确的目录下运行安装脚本" -ForegroundColor Red
        exit 1
    }
}

# 检测 PowerShell 配置文件
$PROFILE_PATH = $PROFILE.CurrentUserCurrentHost
if (-not (Test-Path $PROFILE_PATH)) {
    New-Item -ItemType File -Path $PROFILE_PATH -Force | Out-Null
}

# 检查是否已经安装过
$profileContent = Get-Content $PROFILE_PATH -ErrorAction SilentlyContinue
if ($profileContent -match "function org-create|function org-check|function org-help|buildsense-ai 团队工具") {
    Write-Host "⚠️  工具已安装，正在更新..." -ForegroundColor Yellow
    # 简单粗暴的清理：移除所有包含相关关键字的行及其前后空行
    $cleanContent = @()
    $inOrgBlock = $false
    
    for ($i = 0; $i -lt $profileContent.Length; $i++) {
        $line = $profileContent[$i]
        
        # 检测 buildsense-ai 工具块的开始
        if ($line -match "# buildsense-ai 团队工具") {
            $inOrgBlock = $true
            continue
        }
        
        # 检测函数结束（最后一个 } 且下一行为空或文件结束）
        if ($inOrgBlock -and $line.Trim() -eq "}" -and 
            ($i -eq $profileContent.Length - 1 -or $profileContent[$i + 1].Trim() -eq "")) {
            $inOrgBlock = $false
            continue
        }
        
        # 如果在org块中，跳过所有行
        if ($inOrgBlock) {
            continue
        }
        
        # 保留其他内容
        $cleanContent += $line
    }
    
    # 去除末尾的空行
    while ($cleanContent.Count -gt 0 -and $cleanContent[-1].Trim() -eq "") {
        $cleanContent = $cleanContent[0..($cleanContent.Count - 2)]
    }
    
    $cleanContent | Set-Content $PROFILE_PATH
}

# 使用逐行写入确保格式正确
$lines = @(
    "# buildsense-ai 团队工具",
    "function org-create {",
    "    param([string]`$RepoName, [string]`$Visibility)",
    "    & `"$TOOLS_DIR\github-org-tools.ps1`" create `$RepoName `$Visibility",
    "}",
    "",
    "function org-check {",
    "    & `"$TOOLS_DIR\github-org-tools.ps1`" check",
    "}",
    "",
    "function org-help {", 
    "    & `"$TOOLS_DIR\github-org-tools.ps1`" help",
    "}"
)

# 写入配置文件
$lines | Set-Content -Path $PROFILE_PATH -Encoding UTF8

# 验证安装是否成功
try {
    # 测试配置文件语法
    $testScript = [ScriptBlock]::Create((Get-Content $PROFILE_PATH -Raw))
    Write-Host "✅ 安装完成！" -ForegroundColor Green
} catch {
    Write-Host "❌ 配置文件语法错误，使用备用方法..." -ForegroundColor Red
    # 备用方法：逐行写入
    $lines = @(
        "# buildsense-ai 团队工具",
        "function org-create {",
        "    param([string]`$RepoName, [string]`$Visibility)",
        "    & `"$TOOLS_DIR\github-org-tools.ps1`" create `$RepoName `$Visibility",
        "}",
        "",
        "function org-check {",
        "    & `"$TOOLS_DIR\github-org-tools.ps1`" check", 
        "}",
        "",
        "function org-help {",
        "    & `"$TOOLS_DIR\github-org-tools.ps1`" help",
        "}"
    )
    $lines | Set-Content -Path $PROFILE_PATH -Encoding UTF8
    Write-Host "✅ 备用方法安装完成！" -ForegroundColor Green
}
Write-Host "📝 已添加以下命令到 PowerShell 配置：" -ForegroundColor Blue
Write-Host "  org-create [仓库名] [可见性]  - 创建组织仓库" -ForegroundColor Gray
Write-Host "  org-check                      - 检查环境依赖" -ForegroundColor Gray
Write-Host "  org-help                       - 显示帮助" -ForegroundColor Gray

Write-Host "🔄 请重新加载 PowerShell 配置：" -ForegroundColor Yellow
Write-Host "  . `$PROFILE" -ForegroundColor Gray
Write-Host ""
Write-Host "🎉 之后就可以在任何项目目录下使用 org-create 命令了！" -ForegroundColor Green 