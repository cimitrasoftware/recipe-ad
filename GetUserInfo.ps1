# Get a User's Account Information in Active Directory
# Author: Tay Kratzer tay@cimitra.com
# Change the context variable to match your system
# Modify Date: 11/9/2020

Param(
    [string] $FirstNameIn,
    [string] $LastNameIn,
    [string] $ContextIn
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


$firstNameInSet = $false
$lastNameInSet = $false
$contextInSet = $false
$setContextInSet = $false
$verboseOutputSet = $false
$modifyUserResult = $true
$sleepTime = 5


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



# Show Help
function ShowHelp{
$scriptName = Split-Path -leaf $PSCommandpath
Write-Host ""
Write-Host "Get User Information From Active Directory Account"
Write-Host ""
Write-Host "[ HELP ]"
Write-Host ""
Write-Host ".\$scriptName -h or -help"
Write-Host ""
Write-Host "[ SCRIPT USAGE ]"
Write-Host ""
Write-Host ".\$scriptName -FirstNameIn <user first name> -LastNameIn <user last name> -ContextIn <Active Directory context (optional if specified in settings.cfg)>"
Write-Host ""
Write-Host "[ EXAMPLES ]"
Write-Host ""
Write-Host "Example: .\$scriptName -FirstNameIn Jane -LastNameIn Doe"
Write-Host ""
Write-Host "-OR-"
Write-Host ""
Write-Host "Example: .\$scriptName -setContext OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com -FirstNameIn Jane -LastNameIn Doe"
Write-Host ""
Write-Host "-OR-"
Write-Host ""
Write-Host "Example: .\$scriptName -FirstNameIn Jane -LastNameIn Doe -ContextIn OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com"
Write-Host ""
Write-Host "[ ERROR HANDLING ]"
Write-Host ""
Write-Host "-showErrors = Show Error Messages"
Write-Host ""
Write-Host "Example: .\$scriptName -showErrors -FirstNameIn Jane -LastNameIn Doe"
Write-Host ""
exit 0
}

if (Write-Output $args | Select-String "\-h\b|\-help\b" )
{
ShowHelp
}

# This script expects 2 arguments
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

# User Name
# Title
# Department
# Description
# Office Phone
# Mobile Phone
# Expire Date
# Account Status: Enabled/Disabled
# Creation Date
# User samAccountName
# User CN Name
# User 


# User Name
# Title
# Department
# Description
# Office Phone
# Mobile Phone
# Expire Date
# Account Status: Enabled/Disabled
# Creation Date
# User samAccountName
# User CN Name
# User 

$theGivenName=""
$theSurname=""
$theMobilePhone=""
$theTitle=""
$theDepartment=""
$theDescription=""
$theOfficePhone=""
$theMobilePhone=""
$theExpirationDate=""
$global:theAccountStatus = $true
$thePasswordSetDate=""
$theCreationDate=""
$theUserSamAccounName=""
$theUserCnName=""





try{
 $theFirstName=Get-ADUser  -properties GivenName -Identity "CN=${firstNameIn} ${lastNameIn},$context" | select GivenName -ExpandProperty GivenName
}catch{}


try{
 $theLastName=Get-ADUser  -properties Surname -Identity "CN=${firstNameIn} ${lastNameIn},$context" | select Surname -ExpandProperty Surname
}catch{}


Write-Output ""
Write-Output "FULL NAME:  ${theFirstName} ${theLastName}"
Write-Output "FIRST NAME: ${theFirstName}"
Write-Output "LAST  NAME: ${theLastName}"

try{
 $theTitle=Get-ADUser  -properties title -Identity "CN=${firstNameIn} ${lastNameIn},$context" | select title -ExpandProperty title
}catch{}

if($theTitle.Length -gt 0){
Write-Output "TITLE:  $theTitle"
}else{
Write-Output "TITLE:  [NONE]"
}


try{
 $theDepartment=Get-ADUser  -properties department -Identity "CN=${firstNameIn} ${lastNameIn},$context" | select department -ExpandProperty department 
}catch{}

if($theDepartment.Length -gt 0){
Write-Output "DEPARTMENT:  $theDepartment"
}else{
Write-Output "DEPARTMENT:  [NONE]"
}


try{
 $theDescription=Get-ADUser  -properties description -Identity "CN=${firstNameIn} ${lastNameIn},$context" | select description -ExpandProperty description
}catch{}

if($theDescription.Length -gt 0){
Write-Output "DESCRIPTION:  $theDescription"
}else{
Write-Output "DESCRIPTION:  [NONE]"
}


try{
 $theOfficePhone=Get-ADUser -properties OfficePhone -Identity "CN=${firstNameIn} ${lastNameIn},$context" | select OfficePhone -ExpandProperty OfficePhone 
}catch{}

if($theOfficePhone.Length -gt 0){
Write-Output "OFFICE PHONE:  $theOfficePhone"
}else{
Write-Output "OFFICE PHONE:  [NONE]"
}


try{
 $theMobilePhone=Get-ADUser  -properties MobilePhone -Identity "CN=${firstNameIn} ${lastNameIn},$context" | select MobilePhone -ExpandProperty MobilePhone 
}catch{}

if($theMobilePhone.Length -gt 0){
Write-Output "MOBILE PHONE:  $theMobilePhone"
}else{
Write-Output "MOBILE PHONE:  [NONE]"
}


try{
 $theExpirationDate=Get-ADUser -properties AccountExpirationDate -Identity "CN=${firstNameIn} ${lastNameIn},$context" | select AccountExpirationDate -ExpandProperty AccountExpirationDate 
 }catch{}

if($theExpirationDate.Length -gt 0){
Write-Output "ACCOUNT EXPIRES:  $theExpirationDate"
}else{
Write-Output "ACCOUNT EXPIRES:  [NO EXPIRATION DATE]"
}


try{
 $thePasswordSetDate=Get-ADUser -properties PasswordLastSet -Identity "CN=${firstNameIn} ${lastNameIn},$context" | select PasswordLastSet -ExpandProperty PasswordLastSet 
}catch{}


if($thePasswordSetDate.Length -gt 0){
Write-Output "PASSWORD SET DATE:  $thePasswordSetDate"
}else{
Write-Output "PASSWORD SET DATE:  [NONE]"
}


try{
 $theAccountStatus=Get-ADUser -properties Enabled -Identity "CN=${firstNameIn} ${lastNameIn},$context" | select Enabled -ExpandProperty Enabled 
}catch{}

if($theAccountStatus){
Write-Output "ACCOUNT ENABLED:  YES"
}else{
Write-Output "ACCOUNT ENABLED:  NO"
}


try{
 $theCreationDate=Get-ADUser  -properties Created -Identity "CN=${firstNameIn} ${lastNameIn},$context" | select Created -ExpandProperty Created 
}catch{}

Write-Output "Account Creation Date:  $theCreationDate"


try{
 $theUserSamAccounName=Get-ADUser  -properties SamAccountName -Identity "CN=${firstNameIn} ${lastNameIn},$context" | select SamAccountName -ExpandProperty SamAccountName 
}catch{}


Write-Output "SamAccountName:  $theUserSamAccounName"


try{
 $DN=Get-ADUser  -properties DistinguishedName -Identity "CN=${firstNameIn} ${lastNameIn},$context" | select DistinguishedName -ExpandProperty DistinguishedName 
}catch{}

 
Write-Output "DISTINGUISHED NAME:  $DN"




