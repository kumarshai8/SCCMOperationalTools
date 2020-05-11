


 Function Reset-CMClientInfo
     

{

       <#
       .SYNOPSIS 
        Clear the SMSCFG and SMS Certs 
 
       .DESCRIPTION 
        Gets the Machine list from imput text file and trigger action on them remotely
 
        .PARAMETERS
        Text file name with machine names  
       
        .EXAMPLE 
        Reset-CMClientInfo -MachineList 'c:\windows\temp\machinenames.txt'
        #>
       Param
         (
        [Parameter(Mandatory=$true)]
        [string]$MachineList
         )
    try
    {
      #CREATE - LOG
      $log = "$env:TEMP\SMSCFGRename.log"


      #LOGGING
      "===================================================================================================" >>$log
      Get-date >>$log
      write-host "Starting batch Execution" -ForegroundColor Green
      "Starting batch Execution" >> $log

      #GET MACHIN LIST
      $Machines = get-content $MachineList -ErrorAction Stop
        

          foreach ($comp in $Machines)
          {

            try
            {
   
                   Write-host ">>>> Working on $comp" -ForegroundColor Yellow
                   ">>>> Working on $comp" >>  $log
   
                   if (Test-Connection -ComputerName $comp -Count 1 -ErrorAction SilentlyContinue)
                   {

                          #STOP SERVICE
                         Write-host "Stopping CCMEXEC service on $comp" -ForegroundColor Yellow
                         "Stopping CCMEXEC service on $comp">>  $log
                        Get-Service -ComputerName $comp -Name 'CCMEXEC' | Stop-Service -Force -Verbose


                        #RENAMING THE FILE and CLEAR SMS CERTS
                        write-host "Renaming the SMSCFG and Clearing the SMS certs on $comp" -ForegroundColor Yellow
                        "Renaming the SMSCFG and Clearing the SMS certs on $comp">>  $log
   
       
                        Invoke-Command -ComputerName $comp -ScriptBlock { 

                            if (test-path 'C:\windows\SMSCFG.INI') #if file present
                            {    
                            $time = get-date -Format HHMMddmmyy 
                            $NewFName =  'SMSNFG'+ $time + '.INI' 
                            Rename-Item  "C:\windows\SMSCFG.INI" -NewName $NewFName 
                            }

                            if (test-path "HKLM\Software\Microsoft\SMS") 
                            {
                            Get-ChildItem Cert:\LocalMachine\SMS  | Remove-Item -verbose}  } -ErrorAction stop
        
         
        
                        #START SERVICE
                        write-host "Starting the CCMEXEC on $comp" -ForegroundColor Yellow
                        "Starting the CCMEXEC on $comp">>  $log
                         Get-Service -ComputerName $comp -Name 'CCMEXEC' | Start-Service -verbose

                        write-host ">>>> Done with $comp"  `n -ForegroundColor Green
                       ">>>> Done with $comp">>  $log
                       


                   }
                   else
                   {
                       write-host "$comp is offline" `n -ForegroundColor Red
                       "$comp is offline" >> $log 
                   

                   }
             }

             catch
             {
                   #Catch the exception here
                     
                   write-host "Exception error on $comp. Please check the log"  `n -ForegroundColor Red
                    "$comp has thrown an error $($_.exception)"  >> $log
                    

             }

           }

     }
     catch
     {
                   #Catch the exception here
                     
                   write-host "Exception error occured. Please check the log" -ForegroundColor Red
                    "Exception error >>> $($_.exception)"  >> $log

     }
        


           
       Write-Host  "Completed the execution.. Thank You!" -ForegroundColor green
       "=====================================>> Completed execution <<==========================================" >> $log


 
 }
