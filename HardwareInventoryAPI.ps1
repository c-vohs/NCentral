#New-NCentralConnection -ServerFQDN "ncod460.n-able.com" -JWT "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJTb2xhcndpbmRzIE1TUCBOLWNlbnRyYWwiLCJ1c2VyaWQiOjE1NDEzMTMxODQsImlhdCI6MTYzOTc0NzExOX0.PELr7D37cWISsUPXjWcmHeD4e_ABZPYkkm4BO6_pBc8"

#$devArray = Get-NCDeviceList -CustomerIDs 100 | select deviceid, customername, sitename, longname, deviceclass, lastloggedinuser, supportedos, uri

#$devArray = Get-NCDeviceList -CustomerIDs 102 | select deviceid, customername, sitename, longname, deviceclass, lastloggedinuser, supportedos, uri

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
        DeviceID         = $device.deviceid
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
    }
}

#$results | Out-GridView
$results | Export-Csv -NoTypeInformation C:\Temp\HardwareReport.csv

