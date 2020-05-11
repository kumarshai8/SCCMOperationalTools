#### Spreadsheet Location
 $DirectoryToSaveTo = "C:\PowerShell\Get-KBStatus\1\"
 $date=Get-Date -format "yyyy-MM-d"
 $Filename="Patchinfo-$($date)"

 
 ###InputLocation
 $Computers = Get-Content "C:\PowerShell\Get-KBStatus\1\ServerList.txt"
 # Enter KB to be checked here
 $Patches = Get-Content "C:\PowerShell\Get-KBStatus\1\KBList.txt"
  
# before we do anything else, are we likely to be able to save the file?
# if the directory doesn't exist, then create it
if (!(Test-Path -path "$DirectoryToSaveTo")) #create it if not existing
  {
  New-Item "$DirectoryToSaveTo" -type directory | out-null
  }
  
if (Test-Path -Path "C:\PowerShell\Get-KBStatus\1\KB_Csv.csv")
{
    Remove-Item "C:\PowerShell\Get-KBStatus\1\KB_Csv.csv"
}

$Output = @()
$Output1 = @()

Function GetStatusCode
{
    Param([int] $StatusCode)  
    switch($StatusCode)
    {
        0         {"Success"}
        11001   {"Buffer Too Small"}
        11002   {"Destination Net Unreachable"}
        11003   {"Destination Host Unreachable"}
        11004   {"Destination Protocol Unreachable"}
        11005   {"Destination Port Unreachable"}
        11006   {"No Resources"}
        11007   {"Bad Option"}
        11008   {"Hardware Error"}
        11009   {"Packet Too Big"}
        11010   {"Request Timed Out"}
        11011   {"Bad Request"}
        11012   {"Bad Route"}
        11013   {"TimeToLive Expired Transit"}
        11014   {"TimeToLive Expired Reassembly"}
        11015   {"Parameter Problem"}
        11016   {"Source Quench"}
        11017   {"Option Too Big"}
        11018   {"Bad Destination"}
        11032   {"Negotiating IPSEC"}
        11050   {"General Failure"}
        default {"Failed"}
    }
}



Function GetUpTime
{
    param([string] $LastBootTime)
    $Uptime = (Get-Date) - [System.Management.ManagementDateTimeconverter]::ToDateTime($LastBootTime)
    "Days: $($Uptime.Days); Hours: $($Uptime.Hours); Minutes: $($Uptime.Minutes); Seconds: $($Uptime.Seconds)"
}


foreach ($Computer in $Computers)
 {
    foreach($Patch in $Patches)
    {

        TRY {
             $OS = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $Computer
             $sheetS = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $Computer
             $sheetPU = Get-WmiObject -Class Win32_Processor -ComputerName $Computer
             $drives = Get-WmiObject -ComputerName $Computer Win32_LogicalDisk | Where-Object {$_.DriveType -eq 3}
             $pingStatus = Get-WmiObject -Query "Select * from win32_PingStatus where Address='$Computer'"
             $OSRunning = $OS.caption + " " + $OS.OSArchitecture + " SP " + $OS.ServicePackMajorVersion
             $systemType=$sheetS.SystemType
             $date = Get-Date
             $uptime = $OS.ConvertToDateTime($OS.lastbootuptime)
             $Status = GetStatusCode( $pingStatus.StatusCode )
  
             if($kb=get-hotfix -id $Patch -ComputerName $computer -ErrorAction 2)
             {
                 $kbinstall="$patch is installed"
             }
             else
             {
                 $kbinstall="$patch is not installed"
             }
         }
 
 
         CATCH
         {
             $pcnotfound = "true"
         }
         #### Pump Data to Excel
         if ($pcnotfound -eq "true")
         {
             $Output = [pscustomobject]@{
             Name = $computer
             ConnectionStatus = 'PC Not Found'
             }
         }
         else
         {
            $Output = [pscustomobject]@{
             Name = $computer
             ConnectionStatus = $Status
             PatchStatus = $kbinstall
             OS = $OSRunning
             SystemType = $systemType
             LastBootTime = $uptime
             }             
         }

         $Output1 += $Output
         if($pcnotfound -eq "true")
         {
            $pcnotfound = "false"
            break
         }
    }
}

Add-Content "C:\PowerShell\Get-KBStatus\1\KB_Csv.csv" -Value '"Name","ConnectionStatus","PatchStatus","OS","SystemType","LastBootTime"'
$Output1 | Export-Csv "C:\PowerShell\Get-KBStatus\1\KB_Csv.csv" -Append -Force
