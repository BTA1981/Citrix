<#
.DESCRIPTION
  Log Off disconnected sessions after x days
.INPUTS
  <Inputs if any, otherwise state None>
.OUTPUTS
  <Outputs if any, otherwise state None>
.NOTES
  Version:        1.0
  Author:         BT
  Creation Date:  
  Purpose/Change: Initial script development
.PREREQUISITES
  Citrix snapins (come with Citrix studio installation)

.EXAMPLE
  <Example goes here. Repeat this attribute for more than one example>
  <Example explanation goes here>


param (
        [Parameter(Mandatory=$True)] # 
        [string]$Param1,

        [Parameter(Mandatory=$True)] # 
        [string]$Param2 # 

 ) # End Param
#>
#---------------------------------------------------------[Initialisations]--------------------------------------------------------
[string]$DateStr = (Get-Date).ToString("s").Replace(":","-") # +"_" # Easy sortable date string    
Start-Transcript ('c:\windows\temp\' + $DateStr  + '_LogOff-CitrixSession.log') -Force # Start logging

#Set Error Action to Silently Continue
$ErrorActionPreference = 'SilentlyContinue'
Add-PSSnapin Citrix*
#----------------------------------------------------------[Declarations]----------------------------------------------------------
$DLC =  ""
$i = 0 # don't change
$Days = 2 # Number of days a session may still be disconnected
$SessionState = "Disconnected" # Stop sessions with this status
#-----------------------------------------------------------[Functions]------------------------------------------------------------
#-----------------------------------------------------------[Execution]------------------------------------------------------------
$Sessions = Get-BrokerSession -AdminAddress $DLC | where { $_.SessionState -eq $SessionState }
Write-Host "There are [$($Sessions.count)] with status [$SessionState]"
#$Sessions | select username,sessionstate,starttime
ForEach ($Session in $Sessions) {
    $StartDate = $Session.StartTime

    If ($StartDate -lt ((Get-Date).AddDays(-$Days))) {
        $i = $i + 1
        
        Write-Host "Stopping user session for user [$($Session.UserName)]"
        Write-Host "Session was initiated on [$StartDate]"
        Stop-BrokerSession -InputObject $Session -AdminAddress $DLC -Verbose
    }
}
Stop-Transcript
