Get-Content -path C:\script\Get-SMSGUIDs\computers.txt | foreach { "{0} - {1}" -f $_, (Get-WMIObject -ComputerName $_ -Namespace root\ccm ccm_client clientid | Select-Object clientid).clientid}



