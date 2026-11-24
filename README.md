#  Enterprise IT Onboarding & Automation System

##  Project Overview
This project demonstrates a fully functional IT Administration workflow for a Windows Enterprise environment. It automates the User Provisioning process using PowerShell, eliminating manual errors and reducing onboarding time from 15 minutes to 5 seconds.

##  Infrastructure Built
- **Active Directory:** OUs and Security Groups configured.
- **File Server:** NTFS permissions applied for data segregation.
- **Group Policy (GPO):** Automated drive mapping and endpoint restriction (blocking Control Panel for standard users).

##  The Automation Script
The `Onboard-Employee.ps1` script performs the following tasks in one click:
1. Checks if the user already exists (Error Handling via `Try...Catch`).
2. Prompts for a secure password (No hardcoded passwords).
3. Creates an AD User with a temporary password.
4. Places the user in the correct Organizational Unit (OU).
5. Adds the user to the appropriate Security Group.
6. Creates a dedicated Home Folder on the File Server.
7. Assigns correct NTFS permissions to the Home Folder.

##  Future Enhancements (Hybrid Cloud Readiness)
While this lab is On-Premises only, modern IT environments are hybrid. Future enhancements include:
- **Azure AD Connect:** Syncing on-prem users to Microsoft Entra ID.
- **Microsoft Graph API:** Automating the assignment of M365 licenses during user creation.

##  Evidence
Screenshots of the AD setup, GPOs, script execution, and client-side validation are in the `screenshots/` folder.

##  Skills Demonstrated
- Windows Server Administration
- Active Directory (ADUC)
- Group Policy Management
- PowerShell Scripting & Automation (Try/Catch, SecureString)
- File Server & NTFS Permissions
