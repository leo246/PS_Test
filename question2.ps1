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
    $source = "\\localhost\C$\trayport_test_2\$target\logs\"
    $destination = "\\localhost\C$\trayport_test_2\backups\$target\logs"

    If (!(test-path -path $destination)){
        New-Item -ItemType Directory -Force -Path $destination
    }

    $files = Get-ChildItem -Path $source | Where-Object { !$_.PSIsContainer -and $_.LastWriteTime -lt (Get-Date).Date }

    Foreach ($file in $files) {
        Start-Job -ScriptBlock {
            param($source, $destination)
            Copy-Item -Path $source -Destination $destination
        } -ArgumentList $file.FullName, $destination, $target
    }
}








$files1 = Get-ChildItem -Path $server1Source | Where-Object { !$_.PSIsContainer -and $_.LastWriteTime -lt (Get-Date).Date }

foreach ($file in $files1) {
    
    If (!(test-path -path $server1Dest)){
        New-Item -ItemType Directory -Force -Path $server1Dest
    }

    Start-Job -ScriptBlock {
        param($server1Source, $server1Dest)
        Copy-Item -Path $server1Source -Destination $server1Dest
    } -ArgumentList $file.FullName, $server1Dest
}       



$source = "C:\\path\\to\\source\\"  # replace with your source directory path
$destination = "C:\\path\\to\\destination\\"  # replace with your destination directory path
$targets = @('server1', 'server2')  # list of target servers

$files = Get-ChildItem -Path $source | Where-Object { !$_.PSIsContainer -and $_.LastWriteTime -lt (Get-Date).Date }

foreach ($file in $files) {
    foreach ($target in $targets) {
        Start-Job -ScriptBlock {
            param($src, $dst, $tgt)
            $fullDestination = "\\\\$tgt\\$dst"
            Copy-Item -Path $src -Destination $fullDestination
        } -ArgumentList $file.FullName, $destination, $target
    }
}




$server1Source = "\\localhost\C$\trayport_test_2\server1\logs\"
$server1Dest = "\\localhost\C$\trayport_test_2\backups\server1\logs"
$server2Source = "\\localhost\C$\trayport_test_2\server2\logs\"
$server2Dest = "\\localhost\C$\trayport_test_2\backups\server2\logs"
