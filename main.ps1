#requires -version 5.1
#requires -RunAsAdministrator

# Main Controller for Windows DoS Educational Toolkit
# Strictly for educational purposes on localhost only

# Import modules
$scriptPath = $PSScriptRoot
. "$scriptPath\modules\utils.ps1"
. "$scriptPath\modules\gui.ps1"
. "$scriptPath\modules\syn_flood.ps1"
. "$scriptPath\modules\slowloris.ps1"
. "$scriptPath\modules\dns_amplification.ps1"
. "$scriptPath\modules\udp_flood.ps1"
. "$scriptPath\modules\http_flood.ps1"
. "$scriptPath\modules\icmp_flood.ps1"
. "$scriptPath\modules\arp_spoofing.ps1"
. "$scriptPath\modules\ssl_renegotiation.ps1"
. "$scriptPath\modules\memcached_amp.ps1"
. "$scriptPath\modules\ntp_amp.ps1"

# Initialize application
Initialize-Application

# Load configuration
$config = Get-Content "$scriptPath\config.json" | ConvertFrom-Json

# Main menu
function Show-MainMenu {
    do {
        Clear-Host
        Show-Header
        
        Write-Host " 1. SYN Flood Simulation" -ForegroundColor Cyan
        Write-Host " 2. Slowloris Attack Simulation" -ForegroundColor Cyan
        Write-Host " 3. DNS Amplification Demo" -ForegroundColor Cyan
        Write-Host " 4. UDP Flood Simulation" -ForegroundColor Cyan
        Write-Host " 5. HTTP Flood Simulation" -ForegroundColor Cyan
        Write-Host " 6. ICMP Ping Flood" -ForegroundColor Cyan
        Write-Host " 7. ARP Spoofing Demo" -ForegroundColor Cyan
        Write-Host " 8. SSL/TLS Renegotiation Attack" -ForegroundColor Cyan
        Write-Host " 9. Memcached Amplification" -ForegroundColor Cyan
        Write-Host "10. NTP Amplification" -ForegroundColor Cyan
        Write-Host "11. Performance Monitor" -ForegroundColor Yellow
        Write-Host "12. View Attack Logs" -ForegroundColor Yellow
        Write-Host "13. Configuration Settings" -ForegroundColor Yellow
        Write-Host "14. Legal Documentation" -ForegroundColor Magenta
        Write-Host "15. Exit Toolkit" -ForegroundColor Red
        
        $choice = Read-Host "`nSelect an option [1-15]"
        
        switch ($choice) {
            '1' { Invoke-SYNFloodSimulation -Config $config }
            '2' { Invoke-SlowlorisSimulation -Config $config }
            '3' { Invoke-DNSAmplificationDemo -Config $config }
            '4' { Invoke-UDPFloodSimulation -Config $config }
            '5' { Invoke-HTTPFloodSimulation -Config $config }
            '6' { Invoke-ICMPFloodSimulation -Config $config }
            '7' { Invoke-ARPSpoofingDemo -Config $config }
            '8' { Invoke-SSLRenegotiationAttack -Config $config }
            '9' { Invoke-MemcachedAmplification -Config $config }
            '10' { Invoke-NTPAmplification -Config $config }
            '11' { Start-PerformanceMonitor }
            '12' { Show-AttackLogs }
            '13' { Show-ConfigurationMenu -Config $config }
            '14' { Show-LegalDocumentation }
            '15' { Exit-Toolkit }
            default { Write-Host "Invalid selection" -ForegroundColor Red; Start-Sleep -Seconds 1 }
        }
    } while ($choice -ne '15')
}

# Start application
Show-MainMenu
