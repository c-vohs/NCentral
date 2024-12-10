# Define the command-line parameters to be used by the script
<#
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]$serverHost,
    [Parameter(Mandatory = $true)]$JWT
)
#>

$JWT = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJTb2xhcndpbmRzIE1TUCBOLWNlbnRyYWwiLCJ1c2VyaWQiOjE1NDEzMTMxODQsImlhdCI6MTYzOTc0NzExOX0.PELr7D37cWISsUPXjWcmHeD4e_ABZPYkkm4BO6_pBc8"
$serverHost = "ncod460.n-able.com"

# Generate a pseudo-unique namespace to use with the New-WebServiceProxy
$NWSNameSpace = "NAble" + ([guid]::NewGuid()).ToString().Substring(25)

# Bind to the namespace, using the Webserviceproxy
$bindingURL = "https://" + $serverHost + "/dms2/services2/ServerEI2?wsdl"
$nws = New-Webserviceproxy $bindingURL -Namespace ($NWSNameSpace)

# Set up and execute the query
$Settings = New-Object System.Collections.ArrayList
$Settings.Add(@{key = "listSOs"; value = "True" })

#Attempt to connect
Try {
    $CustomerList = $nws.customerList("", $JWT, $Settings)
    $OrgPropertiesList = $nws.organizationPropertyList("", $JWT, $null, $false)
}
Catch {
    Write-Host Could not connect: $($_.Exception.Message)
    exit
}

$OrgPropertiesHashTable = @{}
foreach ($Org in $OrgPropertiesList) {
    $CustomerOrgProps = @{}
    foreach ($p in $Org.properties) { $CustomerOrgProps[$p.label] = $p.value }
    $OrgPropertiesHashTable[$Org.customerId] = $CustomerOrgProps

}

#Create customer report ArrayList
$CustomersReport = New-Object System.Collections.ArrayList
ForEach ($Entity in $CustomerList) {
    $CustomerAssetInfo = @{}
  
    #Custom select the required columns, use Ordered to keep them in the order we list them in
    ForEach ($item in $Entity.items) { $CustomerAssetInfo[$item.key] = $item.Value }
    $o = [Ordered]@{
        ID                = $CustomerAssetInfo[$Entity.customerid]
        Name              = $CustomerAssetInfo[$Entity.customername]
        parentID          = $CustomerAssetInfo[$Entity.parentid]
        RegistrationToken = $CustomerAssetInfo[$Entity.registrationtoken]
    }

    #Retrieve the properties for the given customer ID
    $p = $OrgPropertiesHashTable[[int]$CustomerAssetInfo[$Entity.customerid]]

    #Merge the two hashtables
    $o = $o + $p
    #Cast the hashtable to a PSCustomObject
    $o = [PSCustomObject]$o
    
    #Add the PSCustomObject to our CustomersReport ArrayLIst
    $CustomersReport.Add($o) > $null
}

#Output to the screen
$CustomersReport | Out-GridView


Get-NCDevicePropertyList -DeviceIDs 407803074