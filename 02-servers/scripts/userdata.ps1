<powershell>
$ErrorActionPreference = 'Stop'
$ProgressPreference   = 'SilentlyContinue'

$Log = 'C:\ProgramData\userdata.log'
New-Item -Path $Log -ItemType File -Force | Out-Null

Start-Transcript -Path $Log -Append -Force

try {
    Write-Output "Starting PowerShell user-data at $(Get-Date -Format o)"

    Write-Output "Installing AD management Windows features"
    Install-WindowsFeature -Name GPMC,RSAT-AD-PowerShell,RSAT-AD-AdminCenter,RSAT-ADDS-Tools,RSAT-DNS-Server
    Write-Output "AD management feature install complete"

    Write-Output "Downloading AWS CLI v2 MSI"
    Invoke-WebRequest https://awscli.amazonaws.com/AWSCLIV2.msi -OutFile C:\Users\Administrator\AWSCLIV2.msi

    Write-Output "Installing AWS CLI v2 MSI"
    Start-Process "msiexec" -ArgumentList "/i C:\Users\Administrator\AWSCLIV2.msi /qn" -Wait -NoNewWindow

    Write-Output "Updating PATH for current session"
    $env:Path += ";C:\Program Files\Amazon\AWSCLIV2"
    Write-Output "AWS CLI path: $((Get-Command aws -ErrorAction SilentlyContinue).Source)"

    Write-Output "Retrieving domain join credentials from Secrets Manager"
    $secretValue  = aws secretsmanager get-secret-value --secret-id ${admin_secret} --query SecretString --output text
    $secretObject = $secretValue | ConvertFrom-Json

    Write-Output "Creating credential object for domain join"
    $password = $secretObject.password | ConvertTo-SecureString -AsPlainText -Force
    $cred     = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $secretObject.username, $password

    Write-Output "Joining AD domain ${domain_fqdn}"
    Add-Computer -DomainName "${domain_fqdn}" -Credential $cred -Force
    Write-Output "Domain join command completed"

    Write-Output "Add users to the Remote Desktop Users Group"
    $domainGroup = "MCLOUD\mcloud-users"
    $maxRetries  = 10
    $retryDelay  = 30

    for ($i = 1; $i -le $maxRetries; $i++) {
        try {
            Write-Output "Attempt $i : Add-LocalGroupMember $domainGroup"
            Add-LocalGroupMember -Group "Remote Desktop Users" -Member $domainGroup -ErrorAction Stop
            Write-Output "SUCCESS: Added $domainGroup to Remote Desktop Users"
            break
        } catch {
            Write-Output "WARN: Attempt $i failed - waiting $retryDelay seconds..."
            Start-Sleep -Seconds $retryDelay
        }
    }

    Write-Output "Rebooting to finalize domain join and apply group policy"
    shutdown /r /t 5 /c "Initial EC2 reboot to join domain" /f /d p:4:1
}
finally {
    Write-Output "User-data finishing at $(Get-Date -Format o)"
    Stop-Transcript | Out-Null
}
</powershell>
