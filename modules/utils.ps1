# Common Utilities Module

function Initialize-Application {
    # Check for administrative privileges
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "This application requires Administrator privileges." -ForegroundColor Red
        Exit 1
    }
    
    # Create log directory
    if (-not (Test-Path "$PSScriptRoot\..\logs")) {
        New-Item -ItemType Directory -Path "$PSScriptRoot\..\logs" | Out-Null
    }
    
    # Load assembly for GUI
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
}

function Show-Header {
    Write-Host @"
    
    ____  ____  ____                        __  __      _   _               _    
   |  _ \/ ___|/ ___| _ __   __ _ _ __ ___ |  \/  | ___| |_| |__   ___   __| |___ 
   | | | \___ \\___ \| '_ \ / _` | '_ ` _ \| |\/| |/ _ \ __| '_ \ / _ \ / _` / __|
   | |_| |___) |___) | |_) | (_| | | | | | | |  | |  __/ |_| | | | (_) | (_| \__ \
   |____/|____/|____/| .__/ \__,_|_| |_| |_|_|  |_|\___|\__|_| |_|\___/ \__,_|___/
                     |_|                  Educational Toolkit v2.0
"@ -ForegroundColor Green
}

function Log-Event {
    param(
        [string]$AttackType,
        [string]$Parameters
    )
    
    $logEntry = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') | $AttackType | $Parameters"
    $logEntry | Out-File "$PSScriptRoot\..\logs\attacks.log" -Append
}

function Show-AttackLogs {
    $logPath = "$PSScriptRoot\..\logs\attacks.log"
    
    if (Test-Path $logPath) {
        Get-Content $logPath | Out-Host
    }
    else {
        Write-Host "No attack logs available." -ForegroundColor Yellow
    }
    
    Read-Host "`nPress Enter to continue"
}

function Show-LegalDocumentation {
    Clear-Host
    Write-Host @"
====================================================================================
                            LEGAL DISCLAIMER AND WARNING
====================================================================================

THIS TOOLKIT IS PROVIDED FOR EDUCATIONAL PURPOSES ONLY. UNAUTHORIZED NETWORK ATTACKS 
ARE ILLEGAL IN MOST COUNTRIES AND MAY RESULT IN SEVERE CRIMINAL PENALTIES.

By using this software, you agree to the following:

1. ALL SIMULATIONS ARE CONFIGURED TO TARGET LOCALHOST (127.0.0.1) ONLY
2. You will NOT modify this software to target external systems
3. You will NOT use this software for any illegal activities
4. You understand cybersecurity risks involved in DoS/DDoS attacks
5. You accept full responsibility for any misuse of this software

Violations may result in prosecution under:
- Computer Fraud and Abuse Act (CFAA) - USA
- Computer Misuse Act 1990 - UK
- Cybercrime Prevention Act of 2012 - Philippines
- Strafgesetzbuch § 202c - Germany
- EU Directive 2013/40/EU

This software implements multiple security measures to prevent misuse:
- Hardcoded target IP (127.0.0.1)
- Admin privilege requirement
- Comprehensive logging
- Network traffic monitoring
- Legal agreement prompts

====================================================================================
"@ -ForegroundColor Magenta
    
    $agreement = Read-Host "`nDo you understand and agree to these terms? (Y/N)"
    if ($agreement -ne 'Y') {
        Exit-Toolkit
    }
}

function Exit-Toolkit {
    Write-Host "Exiting toolkit..." -ForegroundColor Yellow
    Exit
}

function Start-PerformanceMonitor {
    # Real-time performance monitoring
    $cpuCounter = New-Object Diagnostics.PerformanceCounter "Processor", "% Processor Time", "_Total"
    $memCounter = New-Object Diagnostics.PerformanceCounter "Memory", "Available MBytes"
    $netCounter = New-Object Diagnostics.PerformanceCounter "Network Interface", "Bytes Total/sec", (Get-NetAdapter | Where-Object Status -eq "Up").Name
    
    Write-Host "Starting real-time performance monitor (Press Q to quit)" -ForegroundColor Cyan
    
    do {
        $cpu = $cpuCounter.NextValue()
        $mem = $memCounter.NextValue()
        $net = $netCounter.NextValue() / 1MB
        
        Clear-Host
        Show-Header
        
        Write-Host "CPU Usage: $([math]::Round($cpu))%"
        Write-Host "Available Memory: $([math]::Round($mem)) MB"
        Write-Host "Network Throughput: $([math]::Round($net, 2)) MB/s`n"
        
        # Simple graph visualization
        $cpuBar = "[" + ("#" * [math]::Min(50, [int]($cpu/2))) + (" " * (50 - [math]::Min(50, [int]($cpu/2)))) + "]"
        $memBar = "[" + ("#" * [math]::Min(50, [int]((100 - ($mem/ (Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory * 1000))/2))) + (" " * (50 - [math]::Min(50, [int]((100 - ($mem/ (Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory * 1000))/2)))) + "]"
        
        Write-Host "CPU: $cpuBar" -ForegroundColor Yellow
        Write-Host "MEM: $memBar" -ForegroundColor Green
        
        Start-Sleep -Seconds 1
    } until ([Console]::KeyAvailable -and ($key = [Console]::ReadKey($true).Key -eq 'Q')
}
