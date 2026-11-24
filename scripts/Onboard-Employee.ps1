#Requires -Version 5.1
#Requires -Modules ActiveDirectory
<#
.SYNOPSIS
Creates a lab AD account, adds its department group, and creates its folder.
.DESCRIPTION
Follows the supplied onboarding workflow. The local folder path matches the
PowerShell screenshots. This script does not create OUs, groups, shares or GPOs.
The department group ACL is inherited unless separately changed by an operator.
#>
[CmdletBinding()]
param (
    [ValidatePattern('^[A-Za-z]+$')]
    [string]$FirstName = 'Ali',
    [ValidatePattern('^[A-Za-z]+$')]
    [string]$LastName = 'Raza',
    [ValidatePattern('^[A-Za-z][A-Za-z0-9_-]*$')]
    [string]$Department = 'Sales',
    [ValidateNotNullOrEmpty()]
    [string]$Domain = 'corp.local',
    [ValidateNotNullOrEmpty()]
    [string]$ShareRoot = 'C:\CompanyShares'
)

Set-StrictMode -Version Latest
$Username = ($FirstName.Substring(0, 1) + $LastName).ToLowerInvariant()
$DomainDN = (($Domain.Split('.') | ForEach-Object { "DC=$_" }) -join ',')
$OUPath = "OU=$Department,OU=Company_Users,$DomainDN"
$Group = "${Department}_Users"
$DepartmentFolder = Join-Path $ShareRoot "${Department}_Data"
$HomeFolder = Join-Path $DepartmentFolder $Username

Write-Host "Starting Onboarding for $FirstName $LastName..." -ForegroundColor Cyan
try {
    if ($Username.Length -gt 20) {
        throw 'The generated sAMAccountName exceeds the 20-character lab limit.'
    }
    $ExistingUser = Get-ADUser -Filter { SamAccountName -eq $Username } -ErrorAction Stop
    if ($ExistingUser) {
        Write-Warning "User $Username already exists! Skipping creation."
        return
    }

    # Validate the lab prerequisites before creating any account.
    Get-ADOrganizationalUnit -Identity $OUPath -ErrorAction Stop | Out-Null
    Get-ADGroup -Identity $Group -ErrorAction Stop | Out-Null
    $NetBIOSDomain = (Get-ADDomain -Identity $Domain -ErrorAction Stop).NetBIOSName
    if (-not (Test-Path -LiteralPath $DepartmentFolder -PathType Container)) {
        throw "Department folder does not exist: $DepartmentFolder"
    }
    if (Test-Path -LiteralPath $HomeFolder) {
        throw "A folder already exists at $HomeFolder; inspect it before provisioning."
    }

    $SecurePassword = Read-Host -AsSecureString "Enter Temporary Password for $Username"
    $UserParameters = @{
        Name = "$FirstName $LastName"
        GivenName = $FirstName
        Surname = $LastName
        SamAccountName = $Username
        UserPrincipalName = "$Username@$Domain"
        Path = $OUPath
        AccountPassword = $SecurePassword
        Enabled = $true
        ChangePasswordAtLogon = $true
        ErrorAction = 'Stop'
    }
    New-ADUser @UserParameters
    Write-Host "[OK] AD User $Username created." -ForegroundColor Green

    Add-ADGroupMember -Identity $Group -Members $Username -ErrorAction Stop
    Write-Host "[OK] Added to $Group group." -ForegroundColor Green

    New-Item -ItemType Directory -Path $HomeFolder -ErrorAction Stop | Out-Null
    $Acl = Get-Acl -LiteralPath $HomeFolder -ErrorAction Stop
    $Rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
        "$NetBIOSDomain\$Username", 'FullControl',
        'ContainerInherit,ObjectInherit', 'None', 'Allow'
    )
    $Acl.SetAccessRule($Rule)
    Set-Acl -LiteralPath $HomeFolder -AclObject $Acl -ErrorAction Stop
    Write-Host '[OK] Home folder created with NTFS permissions.' -ForegroundColor Green
}
catch {
    throw "Failed to onboard '$Username': $($_.Exception.Message) Inspect any partially created account, membership or folder before retrying."
}
