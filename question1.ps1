<#
What code would output to the console the following?
$car1 is a Grey Ford
$car2 is a White Vauxhall
#>

$car1 = New-Object psobject -Property @{Make='Ford';colour='Grey'}
$car2 = New-Object psobject -Property @{Make='Vauxhall';colour='White'}

Write-host '$car1' "is a" $car1.colour $car1.Make
write-host '$car2' "is a" $car2.colour $car2.Make