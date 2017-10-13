#This process is to fully lockout a user from their email and AD acounts as well as create a record of the process.
param([string]$Username = "-")
#Sets parameters to be used throughout script. If a parameter is not correctly specified it will simple cause an error becasue
#the default value, unless otherwise specified is a -
echo "  "
echo "  "

function AccountInfo {
	get-ADUser $Username `
	-properties Enabled `
	| select sAMAccountName,name,enabled
}

function GetGroups {	
	Get-ADPrincipalGroupMembership $Username `
	| select -Expand name
}

function DisableAccount {
	disable-adaccount $Username1 `
	-confirm:$false `
	-verbose
}

#Start-Transcript -Path "C:\Exit_Notice_Log_Files\log$Username.txt"
#Starts creating a full record of the session at C:\Exit_Notice_Log_Files in a new text file with the  
#users E#
echo "  "
echo "  "
echo "User Account Info and status"
#get-ADUser $Username -properties Enabled | select sAMAccountName,name,enabled
#Gets the users ADAccount information
echo "  "
echo "  "
echo "User Groups"
#Get-ADPrincipalGroupMembership $Username | select -Expand name 
#Gets the users current group membership by the name only. -Expand causes it to be seperate from
#the above command otherwise the groups appear as "grp_name_Gro..." and don't continue
echo "  "
echo "  "
echo "Disabling Account"
#disable-adaccount $Username -confirm:$false -verbose
#Disables the Users AD Account and bypasses a confirm if asked.
#Verbose is so that there is some type of flag given that the action was taken
echo "  "
echo "  "
#Get-ADPrincipalGroupMembership -Identity $Username | where {$_.Name -notlike "Domain Users"} | % {Remove-ADPrincipalGroupMembership -Identity $Username -MemberOf $_ -Confirm:$false -Verbose}
#Retrieves the users primary groups memebership and then filters it out to remove the 
#Domain Users group. Then pipes that value it so and removes the groups from that user. 
#Stop-Transcript
#Stops the Transcript