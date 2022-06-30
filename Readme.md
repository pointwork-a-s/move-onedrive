# Move-Onedrive

Very simple implementation of downloading onedrive files from one tenant and uploading to another

The `Connect` function in `connect.ps1` should be updated to how you want to connect to the tenants

## Usage:

`.\download.ps1 2j32jn-my.sharepoint.com 2j32jn.onmicrosoft.com per,pattif`  
Downloads files for the users "per" and "pattif" from the onedrive creates a directory for each  
Adds an file OneNotes.txt specifying which folders are really OneNote Notebooks

`.\upload.ps1 xvb13-my.sharepoint.com xvb13.onmicrosoft.com per,pattif`  
Uploads files for the users "per" and "pattif" from the downloaded directories to onedrive  
Marks the folders from OneNotes.txt as being OneNote Notebooks



### Note:

To be able to actually read documents from users OneDrive and if you are connecting using a user account you will likely have to grant your user site collection admin permissions to the users onedrive. For that you can use the command

`Set-PnPTenantSite -Identity $webUrl -Owners "<<your credentials>>"` 