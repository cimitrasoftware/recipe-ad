﻿# Check Password Set Date in Active Directory
# Author: Tay Kratzer tay@cimitra.com
# Change the context variable to match your system
# Modify Date: 11/9/2020
# -------------------------------------------------

Param(
    [string] $FirstNameIn,
    [string] $LastNameIn,
    [string] $ContextIn,
    [string] $SleepTimeIn
 )

## USING A SETTINGS CONFIGURATION FILE ##
# -------------------------------------------------
# Create a file called settings.cfg
# Add these two fields
# AD_USER_CONTEXT=OU=DEMOUSERS,OU=DEMO,DC=cimitrademo,DC=com
# AD_COMPUTER_CONTEXT=OU=COMPUTERS,OU=DEMO,DC=cimitrademo,DC=com
# Edit the settings to match your Active Directory context for users and computers
# -------------------------------------------------

# -------------------------------------------------
 # $context = "OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com" 
 # - OR -
 # Specify the context in settings.cfg file
 # Use this format: AD_USER_CONTEXT=<ACTIVE DIRECTORY CONTEXT>
 # Example: AD_USER_CONTEXT=OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com
 # - OR -
 # Use the -ContextIn command line variable
 # Example: -ContextIn "OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com"
# -------------------------------------------------


$firstNameInSet = $false
$lastNameInSet = $false
$contextInSet = $false
$setContextInSet = $false
$verboseOutputSet = $false
$modifyUserResult = $true
$sleepTime = 5
$SCRIPT_DESCRIPTION = "Unlock a User's Active Directory Account"


$firstNameIn = $FirstNameIn
$lastNameIn = $LastNameIn

$firstNameIn = [string]::join(" ",($firstNameIn.Split("`n"))).Trim()
$lastNameIn = [string]::join(" ",($lastNameIn.Split("`n"))).Trim()

$firstNameIn = (Get-Culture).TextInfo.ToTitleCase($firstNameIn) 
$lastNameIn = (Get-Culture).TextInfo.ToTitleCase($lastNameIn)


if(Write-Output $args | Select-String '-ContextIn'){
$theArgs = $MyInvocation.Line
$contextIn = $theArgs  -split "(?<=-ContextIn)\s" | Select -Skip 1 -First 1
}

if (Write-Output "$args" | Select-String -CaseSensitive "-ShowErrors" ){
$verboseOutputSet = $true
}

if($firstNameIn.Length -gt 2){
$firstNameInSet = $true
}

if($lastNameIn.Length -gt 2){
$lastNameInSet = $true
}

if($contextIn.Length -gt 2){
$contextInSet = $true
}


# Look to see if a config_reader.ps1 file exists in order to use it's functionality
if((Test-Path ${PSScriptRoot}\config_reader.ps1)){

# If a settings.cfg file exists, let's use that file to reading in variables
if((Test-Path ${PSScriptRoot}\settings.cfg))
{
# Give a short name to the config_reader.ps1 script
$CONFIG_IO="${PSScriptRoot}\config_reader.ps1"

# Source in the configuration reader script
. $CONFIG_IO

# Use the "ReadFromConfigFile" function in the configuration reader script
$CONFIG=(ReadFromConfigFile "${PSScriptRoot}\settings.cfg")
# Map the $context variable to the AD_USER_CONTEXT variable read in from the settings.cfg file
$context = "$CONFIG$AD_USER_CONTEXT"

if ($sleepTimeTest = "$CONFIG$AD_SCRIPT_SLEEP_TIME"){
$sleepTime = "$CONFIG$AD_SCRIPT_SLEEP_TIME"
}

}

}

function CALL_SLEEP{
Write-Output ""
Write-Output "Pausing for $sleepTime Seconds"
Write-Output ""
Start-Sleep -s $sleepTime
}


# Show Help
function ShowHelp{
$scriptName = Split-Path -leaf $PSCommandpath
Write-Host ""
Write-Host "${SCRIPT_DESCRIPTION}"
Write-Host ""
Write-Host "[ HELP ]"
Write-Host ""
Write-Host ".\$scriptName -h or -help"
Write-Host ""
Write-Host "[ SCRIPT USAGE ]"
Write-Host ""
Write-Host ".\$scriptName -FirstNameIn <user first name> -LastNameIn <user last name> -contextIn <Active Directory context (optional if specified in settings.cfg)>"
Write-Host ""
Write-Host "-OR-"
Write-Host ""
Write-Host ".\$scriptName -ContextIn <Active Directory context (optional if specified in settings.cfg)> -FirstNameIn <user first name> -LastNameIn <user last name>"
Write-Host ""
Write-Host "[ EXAMPLES ]"
Write-Host ""
Write-Host "Example: .\$scriptName -FirstNameIn Jane -LastNameIn Doe"
Write-Host ""
Write-Host "-OR-"
Write-Host ""
Write-Host "Example: .\$scriptName -ContextIn OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com -FirstNameIn Jane -LastNameIn Doe"
Write-Host ""
Write-Host "-OR-"
Write-Host ""
Write-Host "Example: .\$scriptName -FirstNameIn Jane -LastNameIn Doe -ContextIn OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com"
Write-Host ""
Write-Host "[ ERROR HANDLING ]"
Write-Host ""
Write-Host "-ShowErrors = Show Error Messages"
Write-Host ""
Write-Host "Example: .\$scriptName -ShowErrors -FirstNameIn Jane -LastNameIn Doe"
Write-Host ""
exit 0
}

if (Write-Output $args | Select-String "\-h\b|\-help\b" )
{
ShowHelp
}


# This script expects 3 arguments, so if the 3rd argument is blank, then show the Help and exit

if (!( $firstNameInSet -and $lastNameInSet )){ 
ShowHelp
 }
# -------------------------------------------------


# If a fourth argument is sent into this script, that fourth argument will be mapped to the $context variable

if(Write-Output $args | Select-String '-ContextIn'){
$theArgs = $MyInvocation.Line
$setContextIn = $theArgs  -split "(?<=-ContextIn)\s" | Select -Skip 1 -First 1
}

if($setContextIn.Length -gt 2){
$setContextInSet = $true
}


if ($contextInSet){ 
    $context = $contextIn
    Write-Output ""
    Write-Output "Modify User in Context: $context"
}else{
    if($setContextInSet){
    $context = $setContextIn
    }
}



try{
Unlock-ADAccount -Identity "CN=${firstNameIn} ${lastNameIn},$context" 
}catch{
$modifyUserResult = $false
$err = "$_"
}


# If exit code from the command was "True" then show a success message

if ($modifyUserResult)
{
Write-Output ""
Write-Output "User: ${firstNameIn} ${lastNameIn} account unlocked in Active Directory"
Write-Output ""
}else{
Write-Output ""
Write-Output "User: ${firstNameIn} ${lastNameIn} account was NOT unlocked in Active Directory"
Write-Output ""
    if ($verboseOutputSet){
    Write-Output "[ERROR MESSAGE BELOW]"
    Write-Output "-----------------------------"
    Write-Output ""
    Write-Output $err
    Write-Output ""
    Write-Output "-----------------------------"
    }
exit 1
}
