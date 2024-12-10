#New-NCentralConnection -ServerFQDN "ncod460.n-able.com" -JWT "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJTb2xhcndpbmRzIE1TUCBOLWNlbnRyYWwiLCJ1c2VyaWQiOjE1NDEzMTMxODQsImlhdCI6MTYzOTc0NzExOX0.PELr7D37cWISsUPXjWcmHeD4e_ABZPYkkm4BO6_pBc8"

$devArray = Get-NCDeviceList -CustomerIDs 100 | select deviceid, customername, sitename, longname, deviceclass, lastloggedinuser, supportedos, uri

#$devArray = Get-NCDeviceList -CustomerIDs 166 | select deviceid, customername, sitename, longname, deviceclass, lastloggedinuser, supportedos, uri

$results = foreach ($device in $devArray) {
    $devicePropList = Get-NCDevicePropertyList $device.deviceid | select "Bitlocker Status", "Bitlocker Encryption Key"
    write-host $devicePropList | fl
    [PSCustomObject]@{
        DeviceID         = $device.deviceid
        CustomerName     = $device.customername
        SiteName         = $device.sitename
        DeviceName       = $device.longname
        MachineType      = $device.deviceclass
        LastLoggedInUser = $device.lastloggedinuser
        OS               = $device.supportedos
        IPAddress        = $device.uri
        BitlockerStatus  = $devicePropList.'Bitlocker Status'
        EncryptionKey    = ($devicePropList.'Bitlocker Encryption Key').trim()
    }
}

#$results | Out-GridView
$OutputCSV = "C:\Temp\BitlockerReport_$((Get-Date -format MM-dd-yyyy).ToString()).csv"
$results | Export-Csv -NoTypeInformation $OutputCSV