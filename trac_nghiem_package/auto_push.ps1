<#
.SYNOPSIS
    auto_push.ps1 - Kịch bản PowerShell tự động Commit & Push lên GitHub.
.EXAMPLE
    .\auto_push.ps1 -Message "Cập nhật đề thi mới"
    .\auto_push.ps1 -Token "ghp_xxxx" -SaveToken
#>
param(
    [string]$Message = "",
    [string]$Token = "",
    [string]$Branch = "main",
    [string]$Remote = "origin",
    [switch]$SaveToken
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# 1. Tìm Git
$gitCmd = Get-Command git.exe -ErrorAction SilentlyContinue
if ($null -eq $gitCmd) {
    $knownGit = "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer\Git\cmd\git.exe"
    if (Test-Path $knownGit) {
        $gitExe = $knownGit
    } else {
        Write-Error "Không tìm thấy git.exe trên máy tính!"
        exit 1
    }
} else {
    $gitExe = $gitCmd.Source
}

Write-Host "🔧 Sử dụng Git: $gitExe" -ForegroundColor Cyan

# 2. Đọc Token nếu có
$activeToken = $Token
if ([string]::IsNullOrWhiteSpace($activeToken)) {
    if (![string]::IsNullOrWhiteSpace($env:GITHUB_TOKEN)) {
        $activeToken = $env:GITHUB_TOKEN
    } elseif (![string]::IsNullOrWhiteSpace($env:GH_TOKEN)) {
        $activeToken = $env:GH_TOKEN
    } elseif (Test-Path "$scriptDir\.env") {
        Get-Content "$scriptDir\.env" | ForEach-Object {
            $line = $_.Trim()
            if ($line -match "^GITHUB_TOKEN=(.+)$") {
                $activeToken = $matches[1].Trim('"').Trim("'")
            }
        }
    }
}

if ($SaveToken -and (![string]::IsNullOrWhiteSpace($Token))) {
    Set-Content -Path "$scriptDir\.env" -Value "# File luu tru GitHub Token tu dong`nGITHUB_TOKEN=$Token" -Encoding UTF8
    if (Test-Path "$scriptDir\.gitignore") {
        $gitIgnore = Get-Content "$scriptDir\.gitignore"
        if ($gitIgnore -notcontains ".env") {
            Add-Content "$scriptDir\.gitignore" "`n.env`n.github_token"
        }
    } else {
        Set-Content "$scriptDir\.gitignore" ".env`n.github_token" -Encoding UTF8
    }
    Write-Host "💾 Đã lưu token vào file .env an toàn!" -ForegroundColor Green
}

# 3. Kiểm tra thay đổi
Push-Location $scriptDir
try {
    $status = & $gitExe status --porcelain
    if (![string]::IsNullOrWhiteSpace($status)) {
        Write-Host "📦 Phát hiện thay đổi. Đang thêm file và commit..." -ForegroundColor Yellow
        & $gitExe add .
        if ([string]::IsNullOrWhiteSpace($Message)) {
            $Message = "Cap nhat tu dong: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        }
        & $gitExe commit -m $Message
    } else {
        Write-Host "ℹ️ Không có thay đổi cục bộ chưa commit." -ForegroundColor Gray
    }

    # 4. Lấy Remote URL
    $remoteUrl = (& $gitExe remote get-url $Remote).Trim()
    Write-Host "🌐 Remote: $remoteUrl" -ForegroundColor Cyan

    $pushTarget = $Remote
    if (![string]::IsNullOrWhiteSpace($activeToken)) {
        Write-Host "🔑 Sử dụng GitHub Token để đẩy tự động..." -ForegroundColor Green
        if ($remoteUrl -match "^https://(.+)$") {
            $cleanUrl = $matches[1]
            if ($cleanUrl.Contains("@")) {
                $cleanUrl = $cleanUrl.Split("@")[1]
            }
            $pushTarget = "https://x-access-token:$($activeToken)@$cleanUrl"
        }
    }

    # 5. Push
    Write-Host "🚀 Đang đẩy lên nhánh '$Branch'..." -ForegroundColor Yellow
    $env:GIT_TERMINAL_PROMPT = "0"
    $env:GCM_INTERACTIVE = "never"
    & $gitExe push $pushTarget $Branch

    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n==================================================" -ForegroundColor Green
        Write-Host "✅ ĐẨY LÊN GITHUB THÀNH CÔNG RỰC RỠ!" -ForegroundColor Green
        Write-Host "🌿 Nhánh: $Branch" -ForegroundColor Green
        Write-Host "==================================================`n" -ForegroundColor Green
    } else {
        Write-Host "`n❌ Đẩy lên thất bại. Hãy kiểm tra quyền hoặc cung cấp Token:" -ForegroundColor Red
        Write-Host "👉 Tạo Token tại: https://github.com/settings/tokens/new?scopes=repo&description=QuizAppAutoPush" -ForegroundColor Yellow
        Write-Host "👉 Sau đó chạy: .\auto_push.ps1 -Token <TOKEN> -SaveToken" -ForegroundColor Yellow
    }
} finally {
    Pop-Location
}
