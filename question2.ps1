<#
Run the following to create a folder structure with some dummy files to help with this test.
#>

$trayport_test_path = '\\localhost\C$\trayport_test_2\'
if (Test-Path -Path $trayport_test_path ) { Remove-Item -Path $trayport_test_path
-Recurse -Force }
New-Item -Force -Type Directory -Path (Join-Path -Path $trayport_test_path -ChildPath '\server1\logs')
New-Item -Force -Type File -Path (Join-Path -Path $trayport_test_path -ChildPath '\server1\logs\svc_1.log')
New-Item -Force -Type File -Path (Join-Path -Path $trayport_test_path -ChildPath '\server1\logs\svc_2.log')
New-Item -Force -Type File -Path (Join-Path -Path $trayport_test_path -ChildPath '\server1\logs\svc_3.log')
New-Item -Force -Type Directory -Path (Join-Path -Path $trayport_test_path -ChildPath '\server2\logs')
New-Item -Force -Type File -Path (Join-Path -Path $trayport_test_path -ChildPath '\server2\logs\svc_1.log')
New-Item -Force -Type File -Path (Join-Path -Path $trayport_test_path -ChildPath '\server2\logs\svc_2.log')
New-Item -Force -Type File -Path (Join-Path -Path $trayport_test_path -ChildPath '\server2\logs\svc_3.log')
New-Item -Force -Type Directory -Path (Join-Path -Path $trayport_test_path -ChildPath '\backups')

<#

Create a script that
- Saves all console output to a text file
- For each object in the array $targets = @('server1','server2')
- Copies files from \\localhost\C$\trayport_test_2\server1\logs\ to
\\localhost\C$\trayport_test_2\backups\server1\logs
- Copying 2 files in parallel
- Files older than today
- Copies files from \\localhost\C$\trayport_test_2\server2\logs\ to
\\localhost\C$\trayport_test_2\backups\server2\logs
- Copying 2 files in parallel
- Files older than today
Other considerations:
- Using Windows built-in tools instead of Powershell cmdlets is accepted.
- Script needs to work from Powershell v5.1 onwards

#>

$ErrorActionPreference="SilentlyContinue"
Start-Transcript -path $trayport_test_path\transcript.txt -append


$targets = @('server1','server2')

Foreach ($target in $targets){
    #Set Source and destination variables
    $source = "\\localhost\C$\trayport_test_2\$target\logs\"
    $destination = "\\localhost\C$\trayport_test_2\backups\$target\logs"

    # Verify if destination path exists, and create if not
    If (!(test-path -path $destination)){
        New-Item -ItemType Directory -Force -Path $destination
    }

    # Enumerate files in the Source folder, where the files are older that today
    $files = Get-ChildItem -Path $source | Where-Object { !$_.PSIsContainer -and $_.LastWriteTime -lt (Get-Date).Date }

    Foreach ($file in $files) {
        Start-Job -ScriptBlock {
            param($source, $destination)
            #Copy files enumerated to destination folder
            Copy-Item -Path $source -Destination $destination
        } -ArgumentList $file.FullName, $destination, $target
    }
}



