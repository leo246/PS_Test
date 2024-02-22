<#
In a Active directory and vmware environment, assuming
- that for Trayport computers, the VM name and the AD computer name are the same
- the computer where the code runs from has all the required Powershell modules, is part of
the trayport.com AD domain and is connected to a vSphere server
Out to console the list of computers hostnames that
- are in the vmware datastore 'P2'
- AND are NOT in the Organizational Unit 'OU=P2,OU=Computers,DC=trayport,DC=com'
Other considerations:
- If you don't have an environment with AD and VMWare, and don't know cmdlet or object
property names, pseudo-code is acceptable
- if easier, amend the OU and Datastore to something that fits your environment
#>




Import-Module VMware.VimAutomation.Core

$vSphereSrv = "vSphere.trayport.com"
Connect-VIServer -Server $vSphereSrv

$DatastoreVMs = Get-Datastore 'P2' | Get-VM


Foreach ($Vm in $DatastoreVMs) {
    $distinguishedName = (Get-ADComputer -Identity $Vm.name).DistinguishedName | where {$_.DistinguishedName -notlike "OU=P2,OU=Computers,DC=trayport,DC=com"}
    Write-Output $distinguishedName
}

Disconnect-VIServer -Server $vSphereSrv -Confirm:$false

