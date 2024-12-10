#This top is connecting and some testing junk

#New-NCentralConnection -ServerFQDN "ncod460.n-able.com" -JWT "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJTb2xhcndpbmRzIE1TUCBOLWNlbnRyYWwiLCJ1c2VyaWQiOjE1NDEzMTMxODQsImlhdCI6MTYzOTc0NzExOX0.PELr7D37cWISsUPXjWcmHeD4e_ABZPYkkm4BO6_pBc8"

#New-NCentralConnection -ServerFQDN "ncod460.n-able.com" -JWT "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJTb2xhcndpbmRzIE1TUCBOLWNlbnRyYWwiLCJ1c2VyaWQiOjIwMjcyNzcxOTEsImlhdCI6MTY0NTc5Nzc2N30._lq6jJWnjtj9qDo5KhM3oNp1cVEbpZ-ABDyd7mddM94"

#"Count of Devices found : " + $DeviceList.count
#"Device list : "
#$DeviceList | ft

#$DeviceProp = Get-NCDeviceInfo -DeviceIDs "868727151"

#$DeviceProp = Get-NCDeviceLocal

#-------------------------------------------------------------------------------
#This section is the powershell script used in the automation script that will make the variable containing all the local users
$localUsers = Get-LocalUser
$lastItem = $localUsers[-1]
$userString = ''

if ($null -eq $localUsers[0]) {  
    $user.Remove($localUsers[0])
}

foreach ($user in $localUsers) {
    $userString += $user

    if ($lastItem -eq $user) {
        if ('True' -eq $user.Enabled) {
            $userString += "(Enabled)"
        }
        if ('False' -eq $user.Enabled) {
            $userString += "(Disabled)"
        }
    }
    else {
        if ('True' -eq $user.Enabled) {
            $userString += "(Enabled), "
        }
        if ('False' -eq $user.Enabled) {
            $userString += "(Disabled), "
        }
    }
}

#$userString

#-------------------------------------------------------------------------------

#Get-NCCustomerList | Select -Property customername, customerid
# MHM is 146

#Get-NCCustomerPropertyList -CustomerIDs $custID

#device id: 1400504258

#Get-NCDevicePropertyList -DeviceIDs 1400504258

#-------------------------------------------------------------------------------
#New-NCentralConnection -ServerFQDN "ncod460.n-able.com" -JWT "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJTb2xhcndpbmRzIE1TUCBOLWNlbnRyYWwiLCJ1c2VyaWQiOjE1NDEzMTMxODQsImlhdCI6MTYzOTc0NzExOX0.PELr7D37cWISsUPXjWcmHeD4e_ABZPYkkm4BO6_pBc8"


#After connected, this is the section that will use the API to grab the custom property and export a report of it

$custID = 165
$DeviceList = Get-NCDeviceList -CustomerIDs $custID

#Grab the Device list/details
$DeviceList = Get-NCDeviceList -CustomerIDs $custID | Select-Object customerid, sitename, longname, deviceid, deviceclass, lastloggedinuser, supportedos, uri
#$DeviceList | gm

#Get the device properties
$DevicePropertyList = Get-NCDevicePropertyList -DeviceIDs $DeviceList.deviceid

#Create array list for table
$DeviceReport = New-Object System.Collections.ArrayList

#Merge
foreach ($Device in $DeviceList) {
    $Properties = $DevicePropertyList | ? { $_.DeviceID -eq $Device.deviceid } | select 'Local Admins'
    $DeviceHashtable = [Ordered]@{}
    $Device.psobject.properties  | ? { $_.Name -ne 'deviceid' } | % { $DeviceHashtable[$_.Name] = $_.Value } 
    $PropertiesHashTable = [Ordered]@{}
    $Properties.psobject.properties | % { $PropertiesHashtable[$_.Name] = $_.Value }
    $ReportItem = $DeviceHashtable + $PropertiesHashTable
    $ReportItem = [PSCustomObject]$ReportItem
    $DeviceReport.Add($ReportItem) > $Null
}

#Output the report to the screen/Gridview
#$DeviceReport | Out-GridView

$DeviceReport | Export-CSV -NoTypeInformation C:\temp\LocalAdminsResport.csv