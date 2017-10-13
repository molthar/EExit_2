#This process is to fully lockout a user from their email and AD acounts as well as create a record of the process.

param (
	# [Parameter(Mandatory=$true)]
	[string] $username,
	[string] $cui_email,
	[string] $path_to_backup,
	[string] $supervisor_email
)
#Setting the parameters that will be used throughout the script. 

if(-not($username)) { Throw "Please enter the Users E#" }
if(-not($cui_email)) { Throw "Please Enter a CUI email address for -cui_email" }
if(-not($path_to_backup)) { Throw "Please enter a path to backup for -path_to_backup WITHOUT THE TRAILING SLASH" }
if(-not($supervisor_email)) { Throw "Please enter the full email of this users supervisor" }

#Validates that a parameter has been set. If not, throws a message asking for input.

$google_drive_folder = "$username_backup_$(get-date -Format MM-dd-yyyy)"
#setting a parameter for a google drive folder name for the backup to google drive. Ex: E00000000_backup_01-25-2015
$current_dir = pwd
#sets a parameter for current directory you run the file from.

function AccountInfo {
	get-ADUser $username `
	-properties Enabled `
	| select sAMAccountName,name,enabled; `
	echo " "
	echo "Member Of"
	Get-ADPrincipalGroupMembership $username `
	| select -Expand name
}
#Retrieves basic AD Account info such as sAMAccountName,name, and if they are Enabled. Also gets the current groups the user is a member of.

function DisableAccount {
	disable-adaccount $username `
	-confirm:$false `
	-verbose
}
#Disables AD Account

function GroupRemoval {
	Get-ADPrincipalGroupMembership `
	-Identity $Username `
	| where {$_.Name -notlike "Domain Users"} `
	| % {Remove-ADPrincipalGroupMembership `
	-Identity $Username -MemberOf $_ -Confirm:$false -Verbose}
}
#Filters and Removes user from all groups but Domain Users.

function CreateDriveFolder {
	cd C:\GAM-CUI; `
	.\gam `
	user "$supervisor_email" `
	add drivefile `
	drivefilename  "$google_drive_folder" `
	mimetype gfolder; `
	cd $current_dir
}
#Puts you in the correct directory to run GAM, Creates a Google Drive folder for the backup to go into in the supervisors google drive. Puts you back in the directory you started in.

function DelegateEmail {
	cd C:\GAM-CUI; `
	$env:OAUTHFILE=".\oauth2.txt-cui.edu_delegate-only"; `
	.\gam user "$cui_email" `
	delegate to `
	"$supervisor_email"; `
	$env:OAUTHFILE=".\oauth2.txt"; `
	cd $current_dir
}
#Puts your computer in the correct directory to use gam. Sets the correct oauth file for email delegation. Delegates the users email to their supervisor, 
#changes the oauth file back to the correct one, then put's you back in the correct directory that you started in. 
#If you are a super user in Google Apps you don't need the oauth file, this is for other admins. The proper oauth file is located in the IT Services Client FT Google Drive.

