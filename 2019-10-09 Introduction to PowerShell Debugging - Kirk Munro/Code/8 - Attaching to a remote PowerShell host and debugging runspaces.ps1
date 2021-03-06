﻿#####################################################################
#
# PSv5: Attaching to a remote PowerShell host and debugging runspaces
#
#####################################################################

# If this isn't Windows PowerShell or PowerShell Core on Windows, it won't work
if ($PSVersionTable -ge '6.0' -and $PSVersionTable.Platform -eq 'Unix') {
    Write-Warning 'This script uses Enter-PSHostProcess which only works on Windows PowerShell or PowerShell Core on Windows.'
    return
}

# First let's fire up a few remote processes that have PowerShell hosts
$sandbox = Join-Path -Path $([Environment]::GetFolderPath('Desktop')) -ChildPath 'PowerShell.org/2018/debugging'
Start-Process -FilePath 'cmd.exe' -WorkingDirectory $sandbox -ArgumentList @(
    '-c'
    "powershell -NoLogo -NoProfile -NoExit -Command . '.\2 - Entering the debugger without breakpoints.ps1'"
)
while (-not ($process = Get-Process -Name powershell -ErrorAction Ignore | Where-Object Id -ne $pid)) {
    Start-Sleep -Milliseconds 250
}
$process

# We can enter the remote process using Enter-PSHostProcess
Enter-PSHostProcess -Process $process

# Have a look at what's running in the remote process
Get-Runspace

# RemoteHost is the runspace created when we entered the process.
# Other runspaces are the runspaces that process was running before
# we entered the process.

# Let's debug the runspace where our script is running
Debug-Runspace -Name Runspace1

# See how even the file opened in ISE? Now all of the debugging
# skills we've been building up apply, so we can step, look at
# variables, etc.

# Let's just detach and let the runspace continue to execute
d

# And when we exit the remote process, the remote files close
Exit-PSHostProcess

# Now we can stop our process
Stop-Process -InputObject $process