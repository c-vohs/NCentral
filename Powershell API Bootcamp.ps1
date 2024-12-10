<#
New-NCentralConnection -ServerFQDN "ncod460.n-able.com" -JWT "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJTb2xhcndpbmRzIE1TUCBOLWNlbnRyYWwiLCJ1c2VyaWQiOjE1NDEzMTMxODQsImlhdCI6MTYzOTc0NzExOX0.PELr7D37cWISsUPXjWcmHeD4e_ABZPYkkm4BO6_pBc8"

$DeviceList = Get-NCDeviceList -CustomerIDs "140"

"Count of Devices found : " + $DeviceList.count
"Device list : "
$DeviceList | ft
#>
$devCountTCD = Get-NCDeviceList -CustomerIDs 162
Get-NCDeviceList -CustomerIDs 150
Get-NCDeviceInfo -DeviceIDs 1135267429
get-nccustomerlist | select customername, customerid
Get-NCCustomerPropertyList -CustomerIDs 268
Get-NCDevicePropertyList -DeviceIDs 1135267429 | select "Log4Shell Files Detected", "Log4ShellSearchesFailed"
#-------------------------------------------------------------------------------------------

$JWT = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJTb2xhcndpbmRzIE1TUCBOLWNlbnRyYWwiLCJ1c2VyaWQiOjE1NDEzMTMxODQsImlhdCI6MTYzOTc0NzExOX0.PELr7D37cWISsUPXjWcmHeD4e_ABZPYkkm4BO6_pBc8"
$DeviceID = "903839978"
$serverHost = "ncod460.n-able.com"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$NWSNameSpace = "NAble" + ([guid]::NewGuid()).ToString().Substring(25)
$bindingURL = "https://" + $serverHost + "/dms2/services2/ServerEI2?wsdl"
$nws = New-Webserviceproxy $bindingURL -Namespace ($NWSNameSpace)
$DevicePropertyList = $nws.devicePropertyList("", $JWT, $DeviceID, $null, $null, $null, 0)

"count of CDP found : " + $DevicePropertyList.properties.count
#$DevicePropertyList.properties | ft | Out-File c:\temp\cdp.txt
$DevicePropertyList.properties | ft | Export-Csv -NoTypeInformation C:\Temp\NCentralDeviceProps.csv

<#
$DeviceID = DEVICEIDHERE
$DevicePropertyID = DEVICEPROPERTYIDHERE
$DevicePropertyValue = "VALUE HERE"
$serverHost = "YOURNCENTRALFQDNHERE"
$JWT="INSERTJWTHERE"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$NWSNameSpace = "NAble" + ([guid]::NewGuid()).ToString().Substring(25)
$bindingURL = "https://" + $serverHost + "/dms2/services2/ServerEI2?wsdl"
$nws = New-Webserviceproxy $bindingURL -Namespace ($NWSNameSpace)
$devicepropertiesType = "$NWSNameSpace.deviceProperties"
$devicepropertyType = "$NWSNameSpace.deviceProperty"
$deviceproperties = New-Object -TypeName $devicepropertiesType
$deviceproperty= New-Object -TypeName $devicepropertyType
$deviceproperty.devicePropertyID=$devicepropertyid
$deviceproperty.devicePropertyIDSpecified='true'
$deviceproperty.value=$devicepropertyvalue
$deviceproperties[0].deviceID=$DeviceID
$deviceproperties[0].deviceIDSpecified='true'
$deviceproperties[0].properties=$deviceproperty
$DeviceProperty = [PSObject]@{devicePropertyID=$DevicePropertyID; value=$DeviceProperty
Value; devicePropertyIDSpecified='True';}
$Device = [PSObject]@{deviceID=$DeviceID; properties=$DeviceProperty; deviceIDSpecified
='True';}
$nws.devicePropertyModify("", $JWT, $deviceproperties)


#>