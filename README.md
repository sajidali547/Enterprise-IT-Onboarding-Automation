# Enterprise IT Onboarding and Automation

A Windows Server lab for onboarding a Sales user with Active Directory, PowerShell, a department file share and Group Policy. The evidence shows successful creation of Ali Raza (`araza`), a duplicate-user warning on the next run, a mapped client drive and a client restriction dialog.

## Infrastructure

| Component | Implemented lab value |
| --- | --- |
| Server | Windows Server 2022 |
| Domain | `corp.local` |
| OU | `Company_Users\Sales` |
| Security group | `Sales_Users` |
| Department folder | `C:\CompanyShares\Sales_Data` |
| Share | `\\WIN-F695MU8RFG7\Sales_Data` |
| Mapped drive | `G:` |
| Drive GPO | `Map_Sales_Drive` |
| Control Panel restriction | Enabled in Default Domain Policy in the captured editor |

The reference guide uses Z:; the screenshots show G:, which is used throughout this repository.

## Automation

The script checks for an existing account, securely prompts for a temporary password, creates the user in the department OU, adds the department group, creates the local user folder and adds an NTFS access rule. A duplicate account is skipped.

Run on the configured lab server with Windows PowerShell 5.1 or later, the ActiveDirectory module, and permissions to create users, update membership and manage the department folder:

```powershell
.\scripts\Onboard-Employee.ps1 -FirstName Ali -LastName Raza -Department Sales
```

The OU, group, department folder, SMB share and GPO must already exist. The naming convention uses the first initial and surname; this lab implementation accepts alphabetic first and last names. No password is stored in the script.

The repository script follows the provided guide, uses the local folder path visible in the execution screenshots, and adds prerequisite checks and terminating error handling. The screenshots record the original lab execution. The script has been syntax-checked here; it has not been rerun against the domain as part of documentation.

## Documentation and evidence

- [Structured Word project report](docs/Enterprise-IT-Onboarding-Report.docx)
- [Network drive mapping SOP](docs/SOP-Network-Drive-Mapping.md)
- [Marked screenshots](screenshots/)
- [Unchanged original screenshots](screenshots/originals/)

Colored outline boxes and short labels identify the relevant settings. Image dimensions and every pixel outside those annotation overlays are preserved. The separate originals are byte-for-byte copies of the supplied files. The ninth image records the restriction result separately from the mapped drive.

```text
Enterprise-IT-Onboarding-Automation/
|-- README.md
|-- scripts/
|   `-- Onboard-Employee.ps1
|-- docs/
|   |-- SOP-Network-Drive-Mapping.md
|   `-- Enterprise-IT-Onboarding-Report.docx
`-- screenshots/
    |-- 01-domain-controller.png
    |-- 02-ad-structure.png
    |-- 03-ntfs-permissions.png
    |-- 04-gpo-drive-map.png
    |-- 05-gpo-restrict-panel.png
    |-- 06-script-execution.png
    |-- 07-script-error-handling.png
    |-- 08-client-verification.png
    |-- 09-client-policy-restriction.png
    `-- originals/  (the same nine files without annotations)
```

## Scope and next steps

This is an on-premises lab. The captured parent ACL grants the department group Full Control, so individual folder isolation needs a separate effective-access review. Duplicate-user handling skips creation; it does not reconcile partial runs or roll back prior successful steps. No timed onboarding benchmark is claimed.

Microsoft Entra ID synchronization and Microsoft 365 license assignment remain future enhancements. CMD blocking and hybrid cloud integration are not demonstrated by these screenshots.

## Skills demonstrated

Windows Server administration, Active Directory, Group Policy, PowerShell automation, secure password input, NTFS permissions, client validation and support documentation.

## References

- [Microsoft New-ADUser documentation](https://learn.microsoft.com/en-us/powershell/module/activedirectory/new-aduser?view=windowsserver2025-ps)
- [Microsoft PowerShell try catch finally](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_try_catch_finally?view=powershell-5.1)
