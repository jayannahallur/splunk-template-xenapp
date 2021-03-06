$snapins  = Get-PSSnapin Citrix.XenApp.Commands -ea 0

if ($snapins -eq $null)
{
   Get-PSSnapin -Registered "Citrix.XenApp.Commands" | Add-PSSnapin
}

$FarmName = Get-XAFarm | select -ExpandProperty FarmName
$ScriptRunTime = (get-date).ToFileTime()

Get-XASession -Full -ServerName $env:COMPUTERNAME| ?{ ($_.protocol -ne "console") -and ($_.state -ne "Listening") } | foreach-object {

    $Session = $_
    $output = $Session | Get-Member -MemberType Properties | foreach-object {
        $Key = $_.Name
        $Value = $Session.$Key -join ";"

        if($Key -eq "LogOnTime" -or $Key -eq "CurrentTime") {
            $Value = "{0:MM/dd/yyyy HH:mm:ss} GMT" -f ([datetime]$Value).ToUniversalTime();
        }

        '{0}="{1}"' -f $Key,$Value
    }

    $output += '{0}="{1}"' -f "UserName",($_.AccountName -replace ".*\\(.*)",'$1')
    $output += '{0}="{1}"' -f "FarmName",$FarmName
    
    
    Write-Host ("{0:MM/dd/yyyy HH:mm:ss} - {1}" -f (get-date),( $output -join " " ))

} 
