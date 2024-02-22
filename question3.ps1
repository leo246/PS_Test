<#
Create a script that
- restarts a service name list
- service name list is given as a mandatory parameter
- service names can only be telegraf, filebeat or both
- for a list of servers that is given as a mandatory parameter
- doing up to 3 servers in parallel
- displays how long (in seconds) it took the script from start to end
Other considerations:
- Script needs to work from Powershell v5.1 onwards
#>


param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("telegraf", "filebeat")]
    [string[]]$ServiceNameList,
    [Parameter(Mandatory=$true)]
    [string[]]$ServerList
)

$ScriptBlock = {
    param($Server, $ServiceName)

    # get the service
    $Service = Get-Service -ComputerName $Server -Name $ServiceName -ErrorAction SilentlyContinue

    # If the service exists on server, force a restart of service
    If ($Service) {
        Write-Host "Restarting service $ServiceName on server $Server"
        Get-Service -ComputerName $Server -Name $ServiceName | restart-service -Force -ErrorAction SilentlyContinue
    }
    Else {
        Write-Host "Service $ServiceName not found on server $Server"
    }
}

$StartTime = Get-Date

foreach ($Server in $ServerList) {

    # Get service from each specified server
    foreach ($ServiceName in $ServiceNameList) {
        # For each service specified, run scriptblock to restart each
        Start-Job -ScriptBlock $ScriptBlock -ArgumentList $Server, $ServiceName
        
        while ((Get-Job -State Running).Count -ge 3) {
            Start-Sleep -Seconds 10
        }
    }
}

while ((Get-Job -State Running).Count -gt 0) {
    Start-Sleep -Seconds 10
}

Get-Job | Receive-Job

$EndTime = Get-Date
$Duration = $EndTime - $StartTime
Write-Host "Total time taken: $($Duration.TotalSeconds) seconds"
