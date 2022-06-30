# Move-Onedrive

Very simple implementation of downloading onedrive files from one tenant and uploading to another

The `Connect` function in each of the Powershell files should be updated to how you want to connect to the tenants

## Usage:

`.\download.ps1 2j32jn-my.sharepoint.com 2j32jn.onmicrosoft.com per,pattif`
Downloads files for the users "per" and "pattif" from the onedrive creates a directory for each
Adds an file OneNotes.txt specifying which folders are really OneNote Notebooks

`.\upload.ps1 xvb13-my.sharepoint.com xvb13.onmicrosoft.com per,pattif`
Uploads files for the users "per" and "pattif" from the downloaded directories to onedrive
Marks the folders from OneNotes.txt as being OneNote Notebooks