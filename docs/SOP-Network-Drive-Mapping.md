# Standard Operating Procedure for Network Drive Mapping

## Purpose

Restore access to the Sales department share when drive G: is missing or cannot be opened after workstation setup or sign-in.

## Lab configuration

| Item | Value |
| --- | --- |
| Domain | `corp.local` |
| Group | `CORP\Sales_Users` |
| Share | `\\WIN-F695MU8RFG7\Sales_Data` |
| Drive | `G:` |
| Drive policy | `Map_Sales_Drive` |
| Preference path | User Configuration > Preferences > Windows Settings > Drive Maps |
| Observed settings | Create; Reconnect selected; drive G |

The supplied guide uses Z: as an example; the implemented settings and client screenshot show G:.

## Resolution

1. Confirm the affected user and workstation. Check the user is in `Sales_Users` and has a current domain session. After a membership change, sign out and back in so the user receives a new access token.
2. Confirm the workstation can resolve and reach the server. In PowerShell, check:

   ```powershell
   Resolve-DnsName WIN-F695MU8RFG7
   Test-NetConnection WIN-F695MU8RFG7 -Port 445
   ```

3. Test the UNC path in File Explorer: `\\WIN-F695MU8RFG7\Sales_Data`. If the path fails, investigate DNS, SMB availability, the share name, and both share and NTFS permissions before changing the drive policy.
4. If the UNC path works, review the user's policy results:

   ```cmd
   gpupdate /force
   gpresult /r /scope user
   ```

5. In Group Policy Management, verify the `Map_Sales_Drive` link, user scope, security filtering and any item-level targeting. Those scoping details are not established by the editor screenshot alone.
6. Confirm the drive preference points to the same UNC path, uses G:, and has Reconnect selected. Check whether another local or network drive already uses G:.
7. Sign out and back in if required, then open G: and test a permitted file operation. Record the user, workstation, observed error and resolution.

## Permissions and prevention

The lab screenshot shows `Sales_Users` with Full Control on the department folder and inheritance disabled. That is department-wide access; adding a user ACE on a child folder does not remove existing inherited group access. Review effective access separately before describing individual folders as private. Retain administrator and SYSTEM access when designing a production ACL.

Keep the drive mapping in a documented GPO, verify group targeting, and test with a standard user after policy or permission changes. The Control Panel restriction shown elsewhere in this project is configured in Default Domain Policy, rather than the drive-mapping GPO.

## Evidence

- [Drive preference](../screenshots/04-gpo-drive-map.png)
- [Client drive](../screenshots/08-client-verification.png)
- [NTFS permissions](../screenshots/03-ntfs-permissions.png)
