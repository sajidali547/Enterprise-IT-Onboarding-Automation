# Standard Operating Procedure: Network Drive Mapping

## Issue:
Users complain that they cannot access the shared drive after a fresh PC setup.

## Resolution:
1. Verify if the user is added to the correct Department Security Group.
2. Ensure the PC is connected to the corporate network or VPN.
3. Run `gpupdate /force` on the client PC via CMD.
4. Check if the GPO (`Map_Sales_Drive`) is applied using `gpresult /r`.

## Prevention:
The Group Policy has been updated to automatically map the drive based on the user's department group.
