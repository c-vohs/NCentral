<#
Creates a csv and gridview of all devices in NCentral and certain properties (and custom properties) of those devices.
To change custom properties, change select statement in $devicePropList and adjust PSCustomObject list accordingly
#>

#$devArray = Get-NCDeviceList -CustomerIDs 100 | select deviceid, customername, sitename, longname, deviceclass, lastloggedinuser, supportedos, uri

<#
# Doesn't work but could be useful in the future for hashtables

$deviceList = @{}
foreach ($device in $devArray) {
    $dLoop = @{}

    $devicePropList = Get-NCDevicePropertyList $device.deviceid | select "Log4Shell Files Detected", "Log4Shell Searches Failed"

    foreach ( $property in $device.psobject.properties.name ) {
        $dLoop[$property] = $device.$property
    }

    foreach ( $property in $devicePropList.psobject.properties.name ) {
        $dLoop[$property] = $device.$property
    }

    $deviceList = $deviceList + $dLoop
}
#>

#New-NCentralConnection -ServerFQDN "ncod460.n-able.com" -JWT "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJTb2xhcndpbmRzIE1TUCBOLWNlbnRyYWwiLCJ1c2VyaWQiOjE1NDEzMTMxODQsImlhdCI6MTYzOTc0NzExOX0.PELr7D37cWISsUPXjWcmHeD4e_ABZPYkkm4BO6_pBc8"

$devArray = Get-NCDeviceList -CustomerIDs 100 | select deviceid, customername, sitename, longname, deviceclass, lastloggedinuser, supportedos, uri

#$devArray = Get-NCDeviceList -CustomerIDs 165 | select deviceid, customername, sitename, longname, deviceclass, lastloggedinuser, supportedos, uri

$results = foreach ($device in $devArray){
    $devicePropList = Get-NCDevicePropertyList $device.deviceid | select "TLS", "Online Overnight", "Log4Shell Files Detected", "Log4Shell Searches Failed"
    #Get-NCDeviceInfo 789247677 | fl
    #Get-NCDevicePropertyList 789247677
    #Write-Output $device.longname
    [PSCustomObject]@{
        DeviceID = $device.deviceid
        CustomerName = $device.customername
        SiteName = $device.sitename
        DeviceName = $device.longname
        MachineType = $device.deviceclass
        LastLoggedInUser = $device.lastloggedinuser
        OS = $device.supportedos
        IPAddress = $device.uri
        TLS_Enabled = $devicePropList.TLS
        Online_Overnight = $devicePropList.'Online Overnight'
        FilesDetected = $devicePropList.'Log4Shell Files Detected'
        SearchesFailed = $devicePropList.'Log4Shell Searches Failed'
    }
}

#$results | Out-GridView
$results | Export-Csv -NoTypeInformation C:\Temp\NCentralDeviceProps.csv