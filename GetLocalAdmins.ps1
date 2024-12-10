#$membersString = net localgroup administrators
#$localAdmins = $membersString[6..($membersString.Length - 3)]
$localAdmins = Get-LocalGroupMember -Group "Administrators"
$lastItem = $localAdmins[-1]
$userString = ''

if ($null -eq $localAdmins[0]) {  
        $user.Remove($localAdmins[0])
}

foreach ($user in $localAdmins) {
    $userString += $user.Name
    
    Write-Output $user
    if ($lastItem -eq $user) {
        if($user.PrincipalSource -eq "Local") {
            $userSID = $user.SID.Value
            if ('True' -eq (Get-LocalUser -SID $userSID).Enabled) {
                $userString += "(Enabled)"
            }
            if ('False' -eq (Get-LocalUser -SID $userSID).Enabled) {
                $userString += "(Disabled)"
            }
        }
        else {
            $userString += "(Domain)"
        }
    }
    else {
        if ($user.PrincipalSource -eq "Local") {
            $userSID = $user.SID.Value
            if ('True' -eq (Get-LocalUser -SID $userSID).Enabled) {
                $userString += "(Enabled), "
            }
            if ('False' -eq (Get-LocalUser -SID $userSID).Enabled) {
                $userString += "(Disabled), "
            }
        }
        else {
            $userString += "(Domain), "
        }
    }
}

 $userString



#$adminGroup.psbase.Invoke("Members") | ForEach-Object -Process { $_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)}
#$adminGroup.psbase.invoke("Members")

