while ($true) {

    $ENV = Get-Content .\env.json | ConvertFrom-Json
    $PublicIP = Invoke-RestMethod -Method Get -uri "https://api.ipify.org/"

    $headers = @{
        "Authorization" = "Bearer $($ENV.TOKEN)"
    }

    #### List zones
    $Zones = Invoke-RestMethod -Method Get -Uri "https://api.cloudflare.com/client/v4/zones" -Headers $headers
    $ZoneID = ($Zones.result | Where-Object { $_.name -eq $ENV.ZONE }).id

    #### Get DNS Records
    $DNSRecords = Invoke-RestMethod -Method Get -Uri "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records" -Headers $headers

    $DNSRecord = ($DNSRecords.result | Where-Object { $_.name -eq $ENV.RECORD })

    if ($DNSRecord.content -eq $PublicIP) {
        Write-Host "Same public IP"
    }
    else {
        $headers += @{
            "Content-Type" = "application/json"
        }
        $body = @{
            comment = "Auto-updated public IP - pwsh"
            content = $PublicIP
            name    = $DNSRecord.name
            proxied = $DNSRecord.proxied
            ttl     = $DNSRecord.ttl
            type    = $DNSRecord.type
        } | ConvertTo-Json -Depth 10

        try {
            Invoke-RestMethod -Method Patch -Uri "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records/$($DNSRecord.id)" -Headers $headers -Body $body
            Write-Host "Updated cloudflare IP"
        }
        catch {
            Write-Host "Failed to Update cloudflare IP"
        }
    }

    Start-Sleep -Seconds 3  # wait 5 minutes

}