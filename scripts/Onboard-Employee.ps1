param (
    [string]$FirstName = "Ali",
    [string]$LastName = "Raza",
    [string]$Department = "Sales"
)

$Domain = "corp.local"
$Username = ($FirstName.Substring(0,1) + $LastName).ToLower() # e.g., araza
$OUPath = "OU=$Department,OU=Company_Users,DC=corp,DC=local"
$Group = "${Department}_Users"
$ServerName = $env:COMPUTERNAME
$HomeFolder = "\\$ServerName\CompanyShares\${Department}_Data\$Username"

Write-Host "Starting Onboarding for $FirstName $LastName..." -ForegroundColor Cyan

try {
    # 1. Check if user exists (Error Handling)
    if (Get-ADUser -Filter "SamAccountName -eq '$Username'" -ErrorAction SilentlyContinue) {
        Write-Host "WARNING: User $Username already exists! Skipping creation." -ForegroundColor Yellow
    } 
    else {
        # 2. Prompt for secure password
        $SecurePassword = Read-Host -AsSecureString "Enter Temporary Password for $Username"

        # 3. Create AD User
        New-ADUser -Name "$FirstName $LastName" -SamAccountName $Username -UserPrincipalName "$Username@$Domain" -Path $OUPath -AccountPassword $SecurePassword -Enabled $true -ChangePasswordAtLogon $true
        Write-Host "✅ AD User $Username created." -ForegroundColor Green

        # 4. Add to Group
        Add-ADGroupMember -Identity $Group -Members $Username
        Write-Host "✅ Added to $Group group." -ForegroundColor Green

        # 5. Create Home Folder & Permissions
        New-Item -ItemType Directory -Path $HomeFolder | Out-Null
        $Acl = Get-Acl $HomeFolder
        $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
        $Acl.SetAccessRule($Ar)
        Set-Acl $HomeFolder $Acl
        Write-Host "✅ Home folder created with correct NTFS permissions." -ForegroundColor Green
    }
}
catch {
    Write-Host "CRITICAL ERROR: Failed to onboard user. Reason: $_" -ForegroundColor Red
}
