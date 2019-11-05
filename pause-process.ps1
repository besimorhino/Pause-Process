# Pause/unpause a process. Just provide a PID or a PID from the pipeline
# by Mick Douglas @BetterSafetyNet
# and Aaron Sawyer @CrashingStatic

# License: Creative Commons Attribution
# https://creativecommons.org/licenses/by/4.0

# Warning:
# This script will pause (and unpause) running programs.
# Obviously, this can cause system stability issues.
# The author and contributors of this script assume NO liability for the use of this script.
# Users of this script are **stridently** urged to test in a non-production environment first.

# todos:
# Easy
# create better error logics
# make better help messages

# Mid-level
# add input validation checks
# - is ID an int?

# HARD
# - re-introduce the -Duration option & use ScheduledJob instead of sleep

# Credits:
# Shout out to Dave Kennedy for pointing me to this StackOverflow article.
# https://stackoverflow.com/questions/11010165/how-to-suspend-resume-a-process-in-windows

# Reference links:
# calling Windows API from Powershell
# https://blog.dantup.com/2013/10/easily-calling-windows-apis-from-powershell/

# https://blogs.technet.microsoft.com/heyscriptingguy/2013/06/25/use-powershell-to-interact-with-the-windows-api-part-1/

# https://msdn.microsoft.com/en-us/library/windows/desktop/ms679295(v=vs.85).aspx

# Highly interesting article on how to use specific methods in a dll in PowerShell
# https://social.technet.microsoft.com/Forums/ie/en-US/660c36b5-205c-47b6-8b98-aaa97d69a582/use-powershell-to-automate-powerpoint-document-repair-message-response?forum=winserverpowershell


<#

.SYNOPSIS
This is a PowerShell script which allows one to Pause-Process or UnPause-Process.

.DESCRIPTION
This script will allow users to pause and unpause running commands. This is accomplished by attaching a debugger to the selected process. Removing the debugger allows the program to resume normal operation.

Note: not all programs can be paused in this manner.

.EXAMPLE
Import-Module .\pause-process.ps1

.EXAMPLE
Pause-Process -ID [PID]

.EXAMPLE
UnPause-Process -ID [PID]

.NOTES
This script is under active development.
Until you are comfortable with how this works... DO NOT USE IN PRODUCTION!

.LINK
https://infosecinnovations.com/Alpha-Testing

#>

Add-Type -TypeDefinition @"
            using System;
            using System.Diagnostics;
            using System.Security.Principal;
            using System.Runtime.InteropServices;

            public static class Kernel32
            {
                [DllImport("kernel32.dll")]
                public static extern bool CheckRemoteDebuggerPresent(
                    IntPtr hProcess,
                    out bool pbDebuggerPresent);

                [DllImport("kernel32.dll")]
                public static extern int DebugActiveProcess(int PID);

                [DllImport("kernel32.dll")]
                public static extern int DebugActiveProcessStop(int PID);
            }
"@

function Pause-Process {

[CmdletBinding()]

    Param (
        [parameter(Mandatory=$True, ValueFromPipelineByPropertyName=$True)]
            [alias("OwningProcess")]
            [int]$ID
        )

        Begin{
            # Test to see if this is a running process
            # Get-Process -ID $ID  <--Throws an error if the process isn't running
            # Future feature: Do checks to see if we can pause this process.
            Write-Verbose ("You entered an ID of: $ID")

            if ($ID -le 0) {
                $Host.UI.WriteErrorLine("ID needs to be a positive integer for this to work")
                break
            }
            #Assign output to variable, check variable in if statement
            #Variable null if privilege isn't present
            $privy = whoami /priv
            $dbpriv = $privy -match "SeDebugPrivilege"

            if (!$dbpriv) {
            $Host.UI.WriteErrorLine("You do not have debugging privileges to pause any process")
            break
            }

            $ProcHandle = (Get-Process -Id $ID).Handle
            $DebuggerPresent = [IntPtr]::Zero
            $CallResult = [Kernel32]::CheckRemoteDebuggerPresent($ProcHandle,[ref]$DebuggerPresent)
                if ($DebuggerPresent) {
                    $Host.UI.WriteErrorLine("There is already a debugger attached to this process")
                    break
                }
        }

        Process{
            $PauseResult = [Kernel32]::DebugActiveProcess($ID)
        }

        End{
            if ($PauseResult -eq $False) {
                $Host.UI.WriteErrorLine("Unable to pause process: $ID")
               } else {
                    Write-Verbose ("Process $ID was paused")
                }
            }
}

function UnPause-Process {

[CmdletBinding()]

    Param (
        [parameter(Mandatory=$True, ValueFromPipelineByPropertyName=$True)]
        [alias("OwningProcess")]
        [int]$ID
    )

    Begin{
        Write-Verbose ("Attempting to unpause PID: $ID")
         # Test to see if this is a running process
         # (Get-Process -ID $ID) should throw an error if the process isn't running
         # Future feature: Do checks to see if we can pause this process.
         #try { Get-Process -ID $ID }
         #catch { $Host.UI.WriteErrorLine("This process isn't running") }

         Write-Verbose ("You entered an ID of: $ID")

         if ($ID -le 0) {
             $Host.UI.WriteErrorLine("ID needs to be a positive integer for this to work")
             break
         }
        
         #Variable null if privilege isn't present
         $privy = whoami /priv
         $dbpriv = $privy -match "SeDebugPrivilege"
            
         if (!$dbpriv) {
            $Host.UI.WriteErrorLine("You do not have debugging privileges to unpause any process")
            break
         }
    }

    Process{
        #Attempt the unpause
        $UnPauseResult = [Kernel32]::DebugActiveProcessStop($ID)
    }

    End{
        if ($UnPauseResult -eq $False) {
            $Host.UI.WriteErrorLine("Unable to unpause process $ID. Is it running or gone?")
        } else {
            Write-Verbose ("$ID was resumed")
        }
    }
}
