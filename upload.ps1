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

. .\connect.ps1

###########################################################################
# Inspired by
#Author: Adnan Amin
#blog: Https://mstechtalk.com
#Downloading files from OneDrive to local machine
###########################################################################
function ProcessFolder($folderUrl, $sourceFolder, $isOneNote) {
    $folder = Get-PnPFolder -RelativeUrl $folderUrl

    if (-not (Test-Path -path $sourceFolder)) {
        return
    }
    $existingFiles = Get-PnPProperty -ClientObject $folder -Property Files
    Get-ChildItem $sourceFolder -File | ForEach-Object {
        $file = $_
        if (-not($existingFiles | Where-Object -Property Name -eq $file.Name))
        {
            Write-Host "Copying file " $file.Name " at " $folder.ServerRelativeUrl
            [void](Add-PnPFile -Path $file.FullName -Folder $folder)
        }
    }
    if ($isOneNote) {
        $item = Get-PnPProperty -ClientObject $folder -Property ListItemAllFields
        [void](Get-PnPProperty -ClientObject $item -Property parentList)
        [void](set-pnplistitem -list $item.parentList -identity $item -values @{"HTML_x0020_File_x0020_Type"="OneNote.Notebook"})
    }
}

function EnsureSubFolders($parentFolder, $currentPath, $subFolderNames) {
    $subFolderNames | ForEach-Object {
        $subFolderName = $_
        if ($subFolderName) {
            if (-not ($parentFolder.Folders | Where-Object -Property Name -eq $subFolderName)) {
                $parent = $parentFolder.ServerRelativeUrl
                Write-Host "Creating $subFolderName in $parent"
                [void](Add-PnPFolder -Folder $parentFolder -Name $subFolderName)
            }
        }
    }    
}
function ProcessSubFolders($folder, $folders, $currentPath, $onenotes) {
    foreach ($folder in $folders) {
        [void](Get-PnPProperty -ClientObject $folder -Property ServerRelativeUrl)
        #Avoid Forms folders
        if ($folder.Name -ne "Forms") {
            write-host "Processing folder: ${folder.Name} .. at $currentPath"
            $sourceFolder = Join-Path $currentPath $folder.Name;
            ProcessFolder $folder.ServerRelativeUrl.Substring($web.ServerRelativeUrl.Length) $sourceFolder $onenotes.Contains($sourceFolder)
            $tempfolders = Get-PnPProperty -ClientObject $folder -Property Folders
            $subFolderNames = Get-ChildItem $sourceFolder -Directory | Select-Object -ExpandProperty Name
            EnsureSubFolders $folder $currentPath $subFolderNames
            $tempfolders = Get-PnPProperty -ClientObject $folder -Property Folders
            ProcessSubFolders $web $tempfolders $sourceFolder $onenotes
        }
    }
}

function Upload($user) {
    Connect $user
    $web = Get-PnPWeb -ErrorAction Ignore
    if (-not $web) {
        Write-Error "Could not get site for $user"
        return
    }
    if (-not (Test-Path $user -PathType container)) {
        Write-Error "No folder for $user"
        return
    }
    $list = Get-PNPList -Identity "Documents"
    $onenotes = Get-Content (Join-Path $user 'OneNotes.txt') -ErrorAction Ignore
    if (-not $onenotes) {
        $onenotes = @{}
    }
    ProcessSubFolders $web $list.RootFolder $user $onenotes

}

$users | ForEach-Object {
    Upload $_
}