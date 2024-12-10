
#New-NCentralConnection -ServerFQDN "ncod460.n-able.com" -JWT "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJTb2xhcndpbmRzIE1TUCBOLWNlbnRyYWwiLCJ1c2VyaWQiOjE1NDEzMTMxODQsImlhdCI6MTYzOTc0NzExOX0.PELr7D37cWISsUPXjWcmHeD4e_ABZPYkkm4BO6_pBc8"

$devArray = Get-NCDeviceList -CustomerIDs 100 | select deviceid, customername, sitename, longname, discoveredname, deviceclass, lastloggedinuser, supportedos, uri

#$devArray = Get-NCDeviceList -CustomerIDs 262 | select deviceid, customername, sitename, longname, discoveredname, deviceclass, lastloggedinuser, supportedos, uri

$results = foreach ($device in $devArray) {
   #Get-NCDeviceInfo 789247677 | fl
    #Get-NCDevicePropertyList 789247677
    #Write-Output $device.longname
    if ($device.longname -ne $device.discoveredname) {
        [PSCustomObject]@{
            DeviceID         = $device.deviceid
            CustomerName     = $device.customername
            SiteName         = $device.sitename
            DeviceName       = $device.discoveredname
            Nickname         = $device.longname
            MachineType      = $device.deviceclass
            LastLoggedInUser = $device.lastloggedinuser
            OS               = $device.supportedos
            IPAddress        = $device.uri
        } 
    }
}

#$results | Out-GridView
$results | Export-Csv -NoTypeInformation C:\Temp\NCentralDeviceNicknames.csv