# GitHub 组织工具集 - PowerShell 版本
# 适用于 buildsense-ai 团队
# 支持 Windows PowerShell 和 PowerShell Core

# 配置区域 - 团队成员可以修改这里
$ORG_NAME = "buildsense-ai"
$DEFAULT_VISIBILITY = "public"  # 或 "private"

# 检查依赖
function Test-Dependencies {
    $isValid = $true
    
    # 检查 GitHub CLI
    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
        Write-Host "❌ GitHub CLI (gh) 未安装" -ForegroundColor Red
        Write-Host "请安装 GitHub CLI: https://cli.github.com/" -ForegroundColor Yellow
        $isValid = $false
    }

    # 检查 Git
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Host "❌ Git 未安装" -ForegroundColor Red
        $isValid = $false
    }

    # 检查 GitHub CLI 认证
    try {
        gh auth status 2>$null
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ GitHub CLI 未认证" -ForegroundColor Red
            Write-Host "请运行: gh auth login" -ForegroundColor Yellow
            $isValid = $false
        }
    }
    catch {
        Write-Host "❌ GitHub CLI 认证检查失败" -ForegroundColor Red
        $isValid = $false
    }

    return $isValid
}

# 创建组织仓库
function New-OrgRepo {
    param(
        [string]$RepoName,
        [string]$Visibility
    )
    
    # 如果没有提供仓库名，使用当前目录名
    if ([string]::IsNullOrEmpty($RepoName)) {
        $RepoName = Split-Path -Leaf (Get-Location)
    }
    
    # 如果没有指定可见性，使用默认值
    if ([string]::IsNullOrEmpty($Visibility)) {
        $Visibility = $DEFAULT_VISIBILITY
    }

    Write-Host "🚀 准备在组织 $ORG_NAME 下创建仓库: $RepoName" -ForegroundColor Blue

    # 检查是否在 git 仓库中
    if (-not (Test-Path ".git")) {
        Write-Host "❌ 错误：当前目录不是一个 git 仓库" -ForegroundColor Red
        Write-Host "请先运行: git init" -ForegroundColor Yellow
        return $false
    }

    # 检查是否有提交
    try {
        $logOutput = git log --oneline 2>$null
        if ([string]::IsNullOrEmpty($logOutput)) {
            Write-Host "❌ 错误：仓库中没有任何提交" -ForegroundColor Red
            Write-Host "请先添加文件并提交：git add . && git commit -m 'Initial commit'" -ForegroundColor Yellow
            return $false
        }
    }
    catch {
        Write-Host "❌ 错误：仓库中没有任何提交" -ForegroundColor Red
        Write-Host "请先添加文件并提交：git add . && git commit -m 'Initial commit'" -ForegroundColor Yellow
        return $false
    }

    # 检查是否已经有 remote origin
    try {
        $originUrl = git remote get-url origin 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "⚠️  警告：已经存在 remote origin：" -ForegroundColor Yellow
            Write-Host $originUrl -ForegroundColor Yellow
            $confirm = Read-Host "是否要替换现有的 remote origin? (y/N)"
            if ($confirm -match "^[Yy]$") {
                git remote remove origin
                Write-Host "✅ 已删除现有的 remote origin" -ForegroundColor Green
            }
            else {
                Write-Host "❌ 操作已取消" -ForegroundColor Red
                return $false
            }
        }
    }
    catch {
        # 没有 remote origin，继续
    }

    Write-Host "📦 正在组织 $ORG_NAME 下创建仓库 $RepoName..." -ForegroundColor Blue

    # 创建组织仓库
    if ($Visibility -eq "private") {
        gh repo create "$ORG_NAME/$RepoName" --private --clone=false
    }
    else {
        gh repo create "$ORG_NAME/$RepoName" --public --clone=false
    }

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ 仓库创建成功！" -ForegroundColor Green
        
        # 添加 remote origin
        git remote add origin "https://github.com/$ORG_NAME/$RepoName.git"
        Write-Host "✅ 已添加 remote origin" -ForegroundColor Green
        
        # 配置 Git 使用 GitHub CLI 认证
        git config credential.helper 'gh auth git-credential' 2>$null
        Write-Host "✅ 已配置 Git 认证" -ForegroundColor Green
        
        # 设置默认分支为 main（如果当前不是）
        $currentBranch = git branch --show-current
        if ($currentBranch -ne "main") {
            git branch -M main
            Write-Host "✅ 已将分支重命名为 main" -ForegroundColor Green
        }
        
        # Push 到远程仓库
        Write-Host "📤 正在 push 到远程仓库..." -ForegroundColor Blue
        git push -u origin main
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "🎉 成功！仓库已创建并代码已推送！" -ForegroundColor Green
            Write-Host "🔗 仓库地址: https://github.com/$ORG_NAME/$RepoName" -ForegroundColor Blue
            return $true
        }
        else {
            Write-Host "❌ Push 失败，请检查网络连接或权限" -ForegroundColor Red
            return $false
        }
    }
    else {
        Write-Host "❌ 仓库创建失败，请检查：" -ForegroundColor Red
        Write-Host "   1. 你是否有在组织 $ORG_NAME 下创建仓库的权限" -ForegroundColor Yellow
        Write-Host "   2. 仓库名 $RepoName 是否已经存在" -ForegroundColor Yellow
        Write-Host "   3. GitHub CLI 是否正确认证" -ForegroundColor Yellow
        return $false
    }
}

# 显示帮助
function Show-Help {
    Write-Host "GitHub 组织工具集 - buildsense-ai 团队" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "使用方法:" -ForegroundColor White
    Write-Host "  .\github-org-tools.ps1 create [仓库名] [可见性]   - 创建组织仓库并推送" -ForegroundColor Gray
    Write-Host "  .\github-org-tools.ps1 check                      - 检查环境依赖" -ForegroundColor Gray
    Write-Host "  .\github-org-tools.ps1 help                       - 显示此帮助" -ForegroundColor Gray
    Write-Host ""
    Write-Host "参数说明:" -ForegroundColor White
    Write-Host "  仓库名    可选，默认使用当前目录名" -ForegroundColor Gray
    Write-Host "  可见性    可选，public 或 private，默认为 $DEFAULT_VISIBILITY" -ForegroundColor Gray
    Write-Host ""
    Write-Host "示例:" -ForegroundColor White
    Write-Host "  .\github-org-tools.ps1 create                     # 使用当前目录名创建公开仓库" -ForegroundColor Gray
    Write-Host "  .\github-org-tools.ps1 create my-project          # 创建名为 my-project 的仓库" -ForegroundColor Gray
    Write-Host "  .\github-org-tools.ps1 create my-project private  # 创建私有仓库" -ForegroundColor Gray
}

# 主函数
function Main {
    param([string[]]$Args)
    
    $command = if ($Args.Count -gt 0) { $Args[0] } else { "help" }
    
    switch ($command.ToLower()) {
        "create" {
            if (Test-Dependencies) {
                $repoName = if ($Args.Count -gt 1) { $Args[1] } else { $null }
                $visibility = if ($Args.Count -gt 2) { $Args[2] } else { $null }
                New-OrgRepo -RepoName $repoName -Visibility $visibility
            }
        }
        "check" {
            if (Test-Dependencies) {
                Write-Host "✅ 所有依赖都已安装并配置正确" -ForegroundColor Green
            }
        }
        { $_ -in @("help", "--help", "-h", "") } {
            Show-Help
        }
        default {
            Write-Host "❌ 未知命令: $command" -ForegroundColor Red
            Show-Help
        }
    }
}

# 执行主函数
Main -Args $args 