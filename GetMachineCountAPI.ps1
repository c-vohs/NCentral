#New-NCentralConnection -ServerFQDN "ncod460.n-able.com" -JWT "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJTb2xhcndpbmRzIE1TUCBOLWNlbnRyYWwiLCJ1c2VyaWQiOjE1NDEzMTMxODQsImlhdCI6MTYzOTc0NzExOX0.PELr7D37cWISsUPXjWcmHeD4e_ABZPYkkm4BO6_pBc8"

$devArray = Get-NCDeviceList -CustomerIDs 100 | select deviceid, customername, deviceclass

#$devArray = Get-NCDeviceList -CustomerIDs 165 | select deviceid, customername, deviceclass

$customers = $devArray.customername | Sort-Object | Get-Unique

$results = foreach ($customer in $customers) {
    $devices = $devArray | ? {$_.customername -eq $customer}
    $serverCount = ($devices | ? {$_.deviceclass -eq "Servers - Windows"}).count
    $otherCount = ($devices | ? {($_.deviceclass -ne "Servers - Windows") -and ($_.deviceclass -ne "Switch/Router")}).count

    [PSCustomObject]@{
        Customer = $customer
        ServerCount = $serverCount
        WorkstationLaptopCount = $otherCount
    }
}

#$results | Out-GridView
$results | Export-Csv -NoTypeInformation C:\Temp\NCentralDevicesCount.csv