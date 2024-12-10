
$JWT = "ENTER JAVA WEB TOKEN (JWT) HERE"
$serverAddress = "ENTER YOUR SERVER ADDRESS HERE (NCOD123.N-ABLE.COM FOR EXAMPLE)"

#This creates a connection to your server, you only need to do this once per powershell session.
New-NCentralConnection -ServerFQDN $serverAddress -JWT $JWT

#This line gets a list of all devices, the customer ID 100 should be the top level ID. You can check this by going to that level and downloading an agent, that number will be the ID of that "Customer"
$devArray = Get-NCDeviceList -CustomerIDs 100 | select deviceid, customername, sitename, longname, deviceclass, lastloggedinuser, supportedos, uri

#If you want to get a report on a specific customer, change the CustomerID as needed, such as with the following line.
#$devArray = Get-NCDeviceList -CustomerIDs 120 | select deviceid, customername, sitename, longname, deviceclass, lastloggedinuser, supportedos, uri

#Change to whatever software you are searching for
$software = "Adobe"

function format-softList {
    param($softList)
    
    $lastItem = $softList[-1]
    $softListString = ''

    foreach ($item in $softList) {
        $softListString += $item.displayname
        
        if ($lastItem -eq $item) {
            #nothing to do, last item
        }
        else {
            $softListString += ", "
        }
    }
    return $softListString
}

$results = foreach ($device in $devArray) {
    #Write-Host $device.longname

    $softList = (Get-NCDeviceObject -DeviceIDs $device.deviceid).application | select "displayname" | ? { $_.displayname -like "*$software*" } 
    $softString = `
        if ($null -ne $softList) {
        format-softList $softList
    }
    else {
        "Not Applicable"
    }

    [PSCustomObject]@{
        DeviceID         = $device.deviceid
        CustomerName     = $device.customername
        SiteName         = $device.sitename
        DeviceName       = $device.longname
        MachineType      = $device.deviceclass
        LastLoggedInUser = $device.lastloggedinuser
        OS               = $device.supportedos
        IPAddress        = $device.uri
        Software         = $softString
    }
}

$results | Out-GridView
$results | Export-Csv -NoTypeInformation C:\Temp\SoftwareReport.csv

