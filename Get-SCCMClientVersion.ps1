$Servers = Get-Content -path "C:\script\computer.txt"
$Array = @()
 
ForEach($Server in $Servers)
{
    If((Test-Path \\$Server\c$) -match "False")
    {
        Write-Warning "Failed to connect to $Server"
    }
    Else
    {
        $SCCMClient = $null
        $Object = $null
 
        $SCCMClient = (Get-WMIObject -ComputerName $Server -Namespace root\ccm -Class sms_client).ClientVersion
 
        If($SCCMClient -ne $null)
        {
            $Object = New-Object PSObject -Property ([ordered]@{ 
 
                Server                = $Server
                "SCCM Client Version"  = $SCCMClient   
                  
            })
         
            # Add object to our array
            $Array += $Object
        }
        Else
        {
            $Object = New-Object PSObject -Property ([ordered]@{ 
 
                Server                = $Server
                "SCCM Client Version"  = "(Null)"  
                  
            })
         
            # Add object to our array
            $Array += $Object
        }
    }                   
}
 
If($Array)
{
    Return $Array
}
Share:
Cl