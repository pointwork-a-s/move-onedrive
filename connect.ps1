function Connect($user) {
    $webUrl = "https://${myHost}/personal/${user}_$($domain -replace '\.','_')"
    Write-Host "Processing $webUrl"
    Connect-PnPOnline -Url $webUrl -CertificatePath .\moca365.pfx -ClientId 1fab0514-3f69-4133-8eaf-40db43364ca0 -Tenant $domain
}