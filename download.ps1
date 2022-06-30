Param(
    [Parameter(Mandatory=$true,
    ValueFromPipeline=$true)]
    [string]
    $myHost,

    [Parameter(Mandatory=$true,
    ValueFromPipeline=$true)]
    [string]
    $domain,

    [Parameter(Mandatory=$true,
    ValueFromPipeline=$true)]
    [string[]]
    $users
)

function Connect($user) {
    $webUrl = "https://${myHost}/personal/${user}_$($domain -replace '\.','_')"
    Write-Host "Processing $webUrl"
    Connect-PnPOnline -Url $webUrl -CertificatePath .\moca365.pfx -ClientId 1fab0514-3f69-4133-8eaf-40db43364ca0 -Tenant $domain
}

###########################################################################
# Inspired by
#Author: Adnan Amin
#blog: Https://mstechtalk.com
#Downloading files from OneDrive to local machine
###########################################################################
function ProcessFolder($folderUrl, $destinationFolder) {

    $folder = Get-PnPFolder -RelativeUrl $folderUrl
    [void](Get-PnPProperty -ClientObject $folder -Property Files)
   
    if (!(Test-Path -path $destinationfolder)) {
        [void](New-Item $destinationfolder -type directory)
    }

    $total = $folder.Files.Count
    For ($i = 0; $i -lt $total; $i++) {
        $file = $folder.Files[$i]
        Write-Host "Copying file " $file.Name " at " $destinationfolder
        Get-PnPFile -ServerRelativeUrl $file.ServerRelativeUrl -Path $destinationfolder -FileName $file.Name -AsFile
    }
}

function ProcessSubFolders($web, $folders, $currentPath) {
    foreach ($folder in $folders) {
        [void](Get-PnPProperty -ClientObject $folder -Property ServerRelativeUrl)
        #Avoid Forms folders
        if ($folder.Name -ne "Forms") {
            write-host "Processing folder: ${folder.Name} .. at $currentPath"
            $targetFolder = Join-Path $currentPath $folder.Name;
            $item = Get-PnPProperty -ClientObject $folder -Property ListItemAllFields
            if ($item -and $item.FieldValues -and $item.FieldValues['HTML_x0020_File_x0020_Type'] -eq 'OneNote.Notebook') {
                Add-Content (Join-Path $user 'OneNotes.txt') $targetFolder
            }
            ProcessFolder $folder.ServerRelativeUrl.Substring($web.ServerRelativeUrl.Length) $targetFolder 
            $tempfolders = Get-PnPProperty -ClientObject $folder -Property Folders
            ProcessSubFolders $web $tempfolders $targetFolder
        }
    }
}

function Download($user) {
    Connect $user
    $web = Get-PnPWeb -ErrorAction Ignore
    if (-not $web) {
        Write-Error "Could not get site for $user"
        return
    }
    $list = Get-PNPList -Identity "Documents"
    Remove-Item $user -Recurse -Force -ErrorAction Ignore
    [void](New-Item $user -type directory)
    Add-Content (Join-Path $user 'OneNotes.txt') 'List of OneNote notebooks'
    ProcessSubFolders $web $list.RootFolder $user

}

$users | ForEach-Object {
    Download $_
}