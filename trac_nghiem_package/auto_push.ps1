param(
    [string]$Message = "",
    [string]$Token = "",
    [string]$Branch = "main",
    [string]$Remote = "origin",
    [switch]$SaveToken
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# 1. Tim Git
$gitCmd = Get-Command git.exe -ErrorAction SilentlyContinue
if ($null -eq $gitCmd) {
    $knownGit = "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer\Git\cmd\git.exe"
    if (Test-Path $knownGit) {
        $gitExe = $knownGit
    } else {
        Write-Error "Khong tim thay git.exe tren he thong!"
        exit 1
    }
} else {
    $gitExe = $gitCmd.Source
}

Write-Host "Su dung Git: $gitExe" -ForegroundColor Cyan

# 2. Doc Token neu co
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
    Set-Content -Path "$scriptDir\.env" -Value "# GitHub Token`nGITHUB_TOKEN=$Token" -Encoding UTF8
    if (Test-Path "$scriptDir\.gitignore") {
        $gitIgnore = Get-Content "$scriptDir\.gitignore"
        if ($gitIgnore -notcontains ".env") {
            Add-Content "$scriptDir\.gitignore" "`n.env`n.github_token"
        }
    } else {
        Set-Content "$scriptDir\.gitignore" ".env`n.github_token" -Encoding UTF8
    }
    Write-Host "Da luu token vao file .env an toan!" -ForegroundColor Green
}

# 3. Kiem tra thay doi
Push-Location $scriptDir
try {
    $status = & $gitExe status --porcelain
    if (![string]::IsNullOrWhiteSpace($status)) {
        Write-Host "Phat hien thay doi. Dang them file va commit..." -ForegroundColor Yellow
        & $gitExe add .
        if ([string]::IsNullOrWhiteSpace($Message)) {
            $Message = "Cap nhat tu dong: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        }
        & $gitExe commit -m $Message
    } else {
        Write-Host "Khong co thay doi cuc bo chua commit." -ForegroundColor Gray
    }

    # 4. Lay Remote URL
    $remoteUrl = (& $gitExe remote get-url $Remote).Trim()
    Write-Host "Remote: $remoteUrl" -ForegroundColor Cyan

    $pushTarget = $Remote
    if (![string]::IsNullOrWhiteSpace($activeToken)) {
        Write-Host "Su dung GitHub Token de day tu dong..." -ForegroundColor Green
        if ($remoteUrl -match "^https://(.+)$") {
            $cleanUrl = $matches[1]
            if ($cleanUrl.Contains("@")) {
                $cleanUrl = $cleanUrl.Split("@")[1]
            }
            $pushTarget = "https://x-access-token:$($activeToken)@$cleanUrl"
        }
    }

    # 5. Push
    Write-Host "Dang day len nhanh '$Branch'..." -ForegroundColor Yellow
    $env:GIT_TERMINAL_PROMPT = "0"
    $env:GCM_INTERACTIVE = "never"
    & $gitExe push $pushTarget $Branch

    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n==================================================" -ForegroundColor Green
        Write-Host "DAY LEN GITHUB THANH CONG RUC RO!" -ForegroundColor Green
        Write-Host "Nhanh: $Branch" -ForegroundColor Green
        Write-Host "==================================================`n" -ForegroundColor Green
    } else {
        Write-Host "`nDay len that bai. Can Token de day tu dong:" -ForegroundColor Red
        Write-Host "1. Tao Token tai: https://github.com/settings/tokens (chon quyen 'repo')" -ForegroundColor Yellow
        Write-Host "2. Chay lenh: .\auto_push.ps1 -Token <TOKEN> -SaveToken" -ForegroundColor Yellow
    }
} finally {
    Pop-Location
}
