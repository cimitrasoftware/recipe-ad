# Change a User Object's Attribute Value in Active Directory
# Author: Tay Kratzer tay@cimitra.com
# Change the context variable to match your system
# Modify Date: 11/9/2020

# These are the switches that take input
Param(
    [string] $FirstNameIn,
    [string] $LastNameIn,
    [string] $InputIn,
    [string] $AdAttributeIn,
    [string] $AdAttributeLabelIn,
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

# Set all internal boolean variables to false 
# -------------------------------------------------
$firstNameInSet = $false
$lastNameInSet = $false
$inputInSet = $false
$contextInSet = $false
$setContextInSet = $false
$verboseOutputSet = $false
$modifyUserResult = $true
$adAttributeInSet = $false
$adAttributeLabelInSet = $false
# -------------------------------------------------

# FIRST NAME INPUT PROCESSING #
# -------------------------------------------------
# Get the -FirstNameIn variable contents and assign to $firstNameIn variable
$firstNameIn = $FirstNameIn
# Remove any trailing spaces after first name
$firstNameIn = [string]::join(" ",($firstNameIn.Split("`n"))).Trim()
# Capitalize the first name according to the local culture standards
$firstNameIn = (Get-Culture).TextInfo.ToTitleCase($firstNameIn) 
# -------------------------------------------------

# LAST NAME INPUT PROCESSING #
# -------------------------------------------------
# Get the -LastNameIn variable contents and assign to $lastNameIn variable
$lastNameIn = $LastNameIn
# Remove any trailing spaces after last name
$lastNameIn = [string]::join(" ",($lastNameIn.Split("`n"))).Trim()
# Capitalize the last name according to the local culture standards
$lastNameIn = (Get-Culture).TextInfo.ToTitleCase($lastNameIn)
# -------------------------------------------------

# ACTIVE DIRECTORY ATTRIBUTE INPUT PROCESSING #
# -------------------------------------------------
# Get the -AdAttributeIn variable contents and assign to $adAttributeIn variable
$adAttributeIn = $AdAttributeIn
# Remove any trailing spaces after the Active Directory Attribute
$adAttributeIn = [string]::join(" ",($adAttributeIn.Split("`n"))).Trim()
# -------------------------------------------------

# ACTIVE DIRECTORY ATTRIBUTE LABEL INPUT PROCESSING #
# -------------------------------------------------
# Get the -AdAttributeLabelIn variable contents and assign to $adAttributeLabelIn variable
$adAttributeLabelIn = $AdAttributeLabelIn
# Remove any trailing spaces after the Active Directory Attribute Label
$adAttributeLabelIn = [string]::join(" ",($adAttributeLabelIn.Split("`n"))).Trim()
# If the Active Directory Attribute Label wasn't passed in use the $adAttributeIn value for the label
if($adAttributeLabelIn.Length -lt 3){
$adAttributeLabelIn = (Get-Culture).TextInfo.ToTitleCase($adAttributeIn)
}
# -------------------------------------------------



# ATTRIBUTE VALUE INPUT PROCESSING #
# -------------------------------------------------
# Get the -InputIn variable contents and assign to $inputIn variable
$inputIn = $InputIn
# Remove any trailing spaces after the input
$inputIn = [string]::join(" ",($inputIn.Split("`n"))).Trim()
# -------------------------------------------------


# CONTEXT IN VARIABLE PROCESSING #
# -------------------------------------------------
if(Write-Output $args | Select-String '-ContextIn'){
$theArgs = $MyInvocation.Line
# Assign the $contextIn variable to the value after the -ContextIn switch
$contextIn = $theArgs  -split "(?<=-ContextIn)\s" | Select -Skip 1 -First 1
}
# -------------------------------------------------

# ERROR HANDLING VISIBLITY TO THE END-USER #
# -------------------------------------------------
# If the -ShowHelp switch is used, then enable verbose output
if (Write-Output "$args" | Select-String -CaseSensitive "-ShowErrors" ){
$verboseOutputSet = $true
}
# -------------------------------------------------

# SEE IF REQUIRED SWITCHES HAVE BEEN USED AND VALUES PASSED TO THOSE SWITCHES #
# -------------------------------------------------

if($firstNameIn.Length -gt 2){
$firstNameInSet = $true
}

if($lastNameIn.Length -gt 2){
$lastNameInSet = $true
}

if($inputIn.Length -gt 2){
$inputInSet = $true
}

if($adAttributeIn.Length -gt 2){
$adAttributeInSet = $true
}

if($contextIn.Length -gt 2){
$contextInSet = $true
}

# -------------------------------------------------



# SEE IF THE -ContextIn SWITCH WAS USED, IF NOT THEN LOOK FOR A settings.cfg FILE #
# -------------------------------------------------

if(!($contextInSet)){

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

}

} }

# -------------------------------------------------

# Show Help
function ShowHelp{
$scriptName = Split-Path -leaf $PSCommandpath
Write-Host ""
Write-Host "Set a User Object Attribute in Active Directory (for example a user's title)"
Write-Host ""
Write-Host "[ HELP ]"
Write-Host ""
Write-Host ".\$scriptName -h or -help"
Write-Host ""
Write-Host "[ SCRIPT USAGE ]"
Write-Host ""
Write-Host ""
Write-Host "[ REQUIRED SWITCHES ]"
Write-Host ""
Write-Host "-AdAttributeIn <active directory attribute for a user, for example: title>"
Write-Host ""
Write-Host "-InputIn <a value that represents the value attribute being modified, for example: 'Chief Accountant'>"
Write-Host ""
Write-Host "-FirstNameIn <user first name, example: 'Alice Ann'>"
Write-Host ""
Write-Host "-LastNameIn <user last name, example: 'Smith'>"
Write-Host ""
Write-Host "-ContextIn <Active Directory context (optional if specified in settings.cfg)>"
Write-Host ""
Write-Host "[ OPTIONAL SWITCHES ]"
Write-Host ""
Write-Host "-AdAttributeLabelIn = The friendly label for the Active Directory attribute, this is used for more friendly output in this script"
Write-Host ""
Write-Host "-ShowErrors = Show Error Messages"
Write-Host ""
Write-Host ".\$scriptName -AdAttributeIn title -setContext <Active Directory context (optional if specified in settings.cfg)>  -InputIn <title>  -FirstNameIn <user first name> -LastNameIn <user last name>"
Write-Host ""
Write-Host "[ EXAMPLES ]"
Write-Host ""
Write-Host "Example: .\$scriptName -AdAttributeIn title -FirstNameIn Jane -LastNameIn Doe -InputIn Auditor"
Write-Host ""
Write-Host "-OR-"
Write-Host ""
Write-Host "Example: .\$scriptName -ContextIn OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com -AdAttributeIn title -FirstNameIn Jane -LastNameIn Doe -InputIn Auditor"
Write-Host ""
Write-Host "-OR-"
Write-Host ""
Write-Host "Example: .\$scriptName -AdAttributeIn title -FirstNameIn Jane -LastNameIn Doe -InputIn Auditor -ContextIn OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com"
Write-Host ""
Write-Host "[ ERROR HANDLING ]"
Write-Host ""
Write-Host "-ShowErrors = Show Error Messages"
Write-Host ""
Write-Host "Example: .\$scriptName -ContextIn 'OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com' -ShowErrors -AdAttributeIn 'title' -AdAttributeLabelIn 'TITLE' -FirstNameIn 'Jane' -LastNameIn 'Doe' -InputIn 'Auditor'"
Write-Host ""
exit 0
}


# Show Help Input
function ShowHelpInput{
Write-Host ""
Write-Host "Please Enter: $adAttributeLabelIn"
Write-Host ""
exit 0
}

# Show Input Help
if (!( $inputInSet )){ 
ShowHelpInput
 }
# -------------------------------------------------

# If the -h or -help switch are passed, show the help
if (Write-Output $args | Select-String "\-h\b|\-help\b" )
{
ShowHelp
}

# If the -InputIn switch value is not filled in then show the Input Help
if (!( $inputInSet )){ 
ShowHelpInput
 }

# This script expects 4 arguments, if they aren't passed in, show help 
if (!( $firstNameInSet -and $lastNameInSet -and $adAttributeInSet -and $inputInSet )){ 
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
    # Write-Output ""
    # Write-Output "Modify User in Context: $context"
}else{
    if($setContextInSet){
    $context = $setContextIn
    }
}

# Modify the Active Directory Users's specified attribute
try{
Set-ADUser -replace @{$adAttributeIn="$inputIn"} -Identity "CN=${firstNameIn} ${lastNameIn},$context"
}catch{
$modifyUserResult = $false
$err = "$_"
}


# If exit code from the New-ADUser command was "True" then show a success message
if ($modifyUserResult)
{
Write-Output ""
Write-Output ""
Write-Output "User: ${firstNameIn} ${lastNameIn} [ $adAttributeLabelIn ] changed to: ${inputIn}"
Write-Output ""
}else{
Write-Output ""
Write-Output ""
Write-Output "User: ${firstNameIn} ${lastNameIn} [ $adAttributeLabelIn ] NOT changed in Active Directory"
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

