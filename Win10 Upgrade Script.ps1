$dir = 'C:\_Windows_FU\packages'


#if $dir does not exist, make it
if(-not (test-path $dir))
{
    write-host "`n`n The directory $dir does not exist, creating... `n`n" -
    mkdir $dir
}


#if test-path returns true then it exists
else
{
    write-host "`n`n The directory $dir already exists `n`n"

}

$webClient = New-Object System.Net.WebClient
$source = 'https://go.microsoft.com/fwlink/?LinkID=799445'
$destination = "$($dir)\Win10Upgrade.exe"

#check if file exists
if(test-path $destination)
{
    write-host "`n`n File Exists...`n Overwriting... `n`n"
}
else{
    write-host "`n`n File does not exist. Installing... `n`n"
}

$webClient.DownloadFile($source,$destination)
Start-Process -FilePath $file -ArgumentList '/quietinstall /skipeula /auto upgrade /copylogs $dir'

