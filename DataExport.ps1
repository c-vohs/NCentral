#New-NCentralConnection -ServerFQDN "ncod460.n-able.com" -JWT "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJTb2xhcndpbmRzIE1TUCBOLWNlbnRyYWwiLCJ1c2VyaWQiOjE1NDEzMTMxODQsImlhdCI6MTYzOTc0NzExOX0.PELr7D37cWISsUPXjWcmHeD4e_ABZPYkkm4BO6_pBc8"

#$devArray = Get-NCDeviceList -CustomerIDs 100 | select deviceid, customername, sitename, longname, deviceclass, lastloggedinuser, supportedos, uri

#$devArray = Get-NCDeviceList -CustomerIDs 281 | select deviceid, customername, sitename, longname, deviceclass, lastloggedinuser, supportedos, uri

function format-driveSizes {
    param($devDrives)
    #$devDrives
    $lastItem = $devDrives[-1]
    $driveSizeString = ''

    foreach ($drive in $devDrives) {
        $driveSizeString += $drive.volumename
        $dsize = [string]([math]::truncate([long]$drive.maxcapacity / 1GB))
        
        if ($lastItem -eq $drive) {
            $driveSizeString += " " + $dsize + " GB"
        }
        else {
            $driveSizeString += " " + $dsize + " GB, "
        }
    }
    return $driveSizeString
}

$results = foreach ($device in $devArray) {
    $devicePropList = Get-NCDevicePropertyList $device.deviceid | select "TLS", "Online Overnight", "Bitlocker Status", "Bitlocker Encryption Key", "Contract - Trend", "IP Address", "Local Users", "Local Admins"
    Write-Host $device.longname
    $deviceHardware = Get-NCDeviceObject $device.deviceid

    $driveList = $deviceHardware.logicaldevice | ? { [long]$_.maxcapacity -gt "32212254720" }
    $driveString = `
        if ($null -ne $driveList) {
            format-driveSizes $driveList
        }
        else {
            "n/a"
        }

    $deviceMemory = [string]([math]::Truncate($deviceHardware.computersystem.totalphysicalmemory/1GB)) + " GB"
    $deviceWarranty = `
        if ($null -ne $deviceHardware.warrantyexpirydate) {
            $deviceHardware.warrantyexpirydate.substring(0,10)
        }
        else {
            "n/a"
        }

    [PSCustomObject]@{
        #DeviceID         = $device.deviceid
        CustomerName     = $device.customername
        SiteName         = $device.sitename
        DeviceName       = $device.longname
        MachineType      = $device.deviceclass
        LastLoggedInUser = $device.lastloggedinuser
        OS               = $device.supportedos
        IPAddress        = $device.uri
        Manufacturer     = $deviceHardware.computersystem.Manufacturer
        Model            = $deviceHardware.computersystem.model 
        SerialNumber     = $deviceHardware.computersystem.serialnumber 
        WarrantyExpiry   = $deviceWarranty
        Processor        = $deviceHardware.processor.name
        CoreCount        = $deviceHardware.processor.numberofcores
        Memory           = $deviceMemory
        DriveCapacity    = $driveString
        TLS_Enabled      = $devicePropList.TLS
        Online_Overnight = $devicePropList.'Online Overnight'
        Bitlocker_Status         = $devicePropList.'Bitlocker Status'
        Bitlocker_Encryption_Key = $devicePropList.'Bitlocker Encryption Key'
        Contract_Trend   = $devicePropList.'Contract - Trend'
        IP_Address       = $devicePropList.'IP Address'
        Local_Users      = $devicePropList.'Local Users'
        Local_Admins     = $devicePropList.'Local Admins'
        
    }
}

#$results | Out-GridView
$OutputCSV = "C:\Temp\DataExport_$((Get-Date -format MM-dd-yyyy).ToString()).csv"
$results | Export-Csv -NoTypeInformation $OutputCSV

#Get-NCDeviceStatus -DeviceIDs "646713484" | select modulename, statestatus