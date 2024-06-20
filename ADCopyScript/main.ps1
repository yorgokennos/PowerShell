#"Global" variables + imports
import-Module ActiveDirectory

$SERVER = "" #enter the domain controller you want to specify.
$COPY = read-host "Enter username to copy from"       
$PASTE = read-host "Enter username to copy to"


#function declaration and definition that will copy ad user info
function copy-script
{
    #function parameters
    param($SERVER, $COPY, $PASTE)

    write-host "`n Copying Info from $COPY -> $PASTE`n"

    #get department from copy in DC4 and set it to the variable $department
    $department = get-ADuser -identity $COPY -properties department -server $SERVER | select-object memberof -expandproperty department

    #get manager from $copy in DC4 and set it to the variable $manager 
    write-host "scraping manager field"
    $manager = get-ADuser -identity $COPY -properties manager -server $SERVER | select-object memberof -expandproperty manager
    write-host "scraping description field"
    $description = get-ADuser -identity $COPY -properties description -server $SERVER | select-object memberof -expandproperty description
    write-host "scraping title field"
    $title = get-ADuser -identity $COPY -properties title -server $SERVER | select-object memberof -expandproperty title

    write-host "`nThe Following will be copied over:`n`tManager: $manager`n`tDescription: $description`n`tTitle: $title`n`n"

    write-host "Setting home drive + directory..."
    set-aduser $PASTE -server $SERVER -homedrive U:
    set-aduser $PASTE -server $SERVER -homedirectory \\clarkfp01\scanning\$paste

    write-host "Setting department"
    set-aduser $PASTE -server $SERVER -department $department
    write-host "Setting manager"
    set-aduser $PASTE -server $SERVER -manager $manager
    write-host "Setting description"
    set-aduser $PASTE -server $SERVER -description $description
    write-host "Setting title"
    set-aduser $PASTE -server $SERVER -title $title

    write-host "`n`nDone, thank you."
}



#"program" execution 

##check to see if both users exist before running the copy script.
if ((get-aduser $COPY -server $SERVER) -AND (get-aduser $PASTE -server $SERVER))
{
    #function call and passing in our "global" arguments
    copy-script -SERVER $SERVER -COPY $COPY -PASTE $PASTE

    #print createduser with additional properties
    get-ADUser $PASTE -server $SERVER -properties whenCreated | Select Name,Enabled,Surname,UserPrincipalName,whenCreated
}
else
{
    write-host "please make sure that both usernames exist and are enterred correctly"
}
