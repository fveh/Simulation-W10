# DNS Amplification Demo Module for Windows

function Invoke-DNSAmplificationDemo {
    param($Config)
    
    Clear-Host
    Show-Header
    Write-Host "=== DNS AMPLIFICATION DEMO ===" -ForegroundColor Cyan
    
    Write-Host "This demonstrates how DNS amplification attacks work"
    Write-Host "All requests are sent to legitimate DNS servers for educational purposes`n"
    
    # Normal DNS query
    Write-Host "Normal DNS Query:" -ForegroundColor Green
    $normalQuery = Resolve-DnsName -Name $Config.test_domain -Server $Config.dns_server -Type A
    $normalSize = [System.Text.Encoding]::ASCII.GetByteCount(($normalQuery | Out-String))
    Write-Host "Response size: $normalSize bytes"
    
    # Amplified DNS query
    Write-Host "`nAmplified DNS Query (ANY):" -ForegroundColor Yellow
    $ampQuery = Resolve-DnsName -Name $Config.test_domain -Server $Config.dns_server -Type ANY
    $ampSize = [System.Text.Encoding]::ASCII.GetByteCount(($ampQuery | Out-String))
    Write-Host "Response size: $ampSize bytes"
    
    $amplificationFactor = [math]::Round($ampSize / $normalSize, 1)
    Write-Host "`nAmplification Factor: ${amplificationFactor}x" -ForegroundColor Red
    
    # Attack simulation explanation
    Write-Host @"
    
    How DNS Amplification Works:
    1. Attacker sends small DNS request (${normalSize} bytes) with spoofed source IP
    2. DNS server responds with large response (${ampSize} bytes) to victim
    3. Amplification factor: ${amplificationFactor}x
    4. Using multiple DNS servers and botnets increases impact
    
    Attack Scenario:
    - Attacker with 1 Mbps connection sends 100 requests/sec
    - Each request triggers ${ampSize} byte response
    - Total attack traffic: $((100 * $ampSize * 8) / 1mb) Mbps
    - Victim receives $((100 * $ampSize * 8) / 1mb) Mbps from a 1 Mbps attacker
    
    Mitigation Strategies:
    - Disable open DNS resolvers
    - Implement response rate limiting
    - Use BCP38 for source address validation
    - Deploy anti-spoofing filters
"@ -ForegroundColor Cyan
    
    Log-Event -AttackType "DNS_Amplification" -Parameters "Domain:$($Config.test_domain) Normal:$normalSize Amp:$ampSize"
    Read-Host "`nPress Enter to continue"
}
