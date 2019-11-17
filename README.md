# Pause-Process
PowerShell script which allows pausing\unpausing Win32/64 exes

## Prerequisites

Windows PowerShell v 3+ (it may work on v 2, but no promise)


## Getting Started

1) Download the pause-proces module in one of next ways

* Github Module Install:

```powershell
iex ('$user="besimorhino";$repo="Pause-Process";'+(new-object net.webclient).DownloadString('https://raw.githubusercontent.com/PsModuleInstall/InstallFromGithub/master/install.ps1'))
```

* Powershell Gallery Installation:

```powershell
Install-Module -Name Pause-Process
```

* Direct script download:

```powershell
iex('$module="pause-process.ps1";$user="besimorhino";$repo="Pause-Process";$folder="$pwd";(new-object net.webclient).DownloadFile("https://raw.githubusercontent.com/$user/$repo/master/$module","$folder\$module")')
```

2) From a PowerShell prompt, load the module.

```powershell
Import-Module Pause-Process
```

or if script download have been used:

```powershell
Import-Module .\pause-process.ps1
```

Note: Depending on your system's configuration, you may need to modify your execution restriction policy. The easiest way to do this is as follows:

```powershell
powershell -ep bypass
```


## About the cmdlet

Pause-Process allows one to pause an executable and unpause (resume) it.

Pause-Process allows defenders to pause a running executable, conduct forensics analysis and then either resume execution via the UnPause-Process method, or if it truly is malicious, simply halt the process.

This technique is relatively safe because while an application is in the paused state, any I/O is placed in a FIFO buffer.  This vastly lowers the likelihood of critical data loss.

The intention of this script is to give one the ability take a more graduated response to a potentially malicious executable.  Without this tool (or one like it), responders can only kill a running executable.  Understandably, this is extremely disruptive to users.  In the event the IoC triggered is a false positive, it means a business critical application or process was needlessly terminated, and most often results in extreme political pressure on the responders who "over reacted".  As a result, defenders are understandably timid, which allows attackers the time they need to race through the victim network.  This project's goal is to allow defenders to be significantly more active, and intervene much more often with suspicious executables.

Be aware that attackers will likely use this technique against your system.  By pausing the execution of a security agent, (your anti-virus solution for instance) an attack could be conducted without that control being able to operate in its normal manner.  It is vital that you remove debug privileges from all users who do not require this level of access.


## Using this cmdlet
This cmdlet is designed to accept a process ID as a mandatory parameter. The argument -ID is is optional, but supplying a PID is not.  

The commands do support -Verbose mode which will give additional information on what is happening as the process is being paused/unpaused. 

While the examples below are given as PowerShell "one liners" they can absolutely be part of a larger script or framework.

Below are examples of how one could use it in the "real world"


### Scenario 1: Specific Known PID
You already know the PID of the process you want to pause.  (ex. process id 1337)

To pause the process:
```
Pause-Process -ID 1337
```

To unpause (resume) the process:
```
UnPause-Process -ID 1337
```
NOTE: this is the only example of where we show UnPause-Process. Its use is identical to Pause-Process.


### Scenario 2: All Instances of a Program
You want to pause all running instances of a specific program. (ex. notepad.exe)

To pause all notepad instances:
```
get-process -Name notepad | Pause-Process
```


### Scenario 3: Specific User
You want to pause all processes run by a specific user (ex bob)
Caution: if you pause all processes run by you, there will almost certainly be adverse consequences.  Most often this results in a locked system where you cannot unpause to resume normal operation. A reboot fixes this issue.

To pause all processes run by Bob:
```
Get-Process -IncludeUserName | where-object UserName -like "*bob*" | Pause-Process
```
Note: using -IncludeUserName requires Admin rights.


### Scenario 4: Network Connections
To pause all processes that are connecting to a specific IP. For instance, you see interaction with a known command and control (c2) server.

This is how you would pause executables affiliated with a TCP based connection to a specific IP

```
Get-NetTCPConnection | where RemoteAddress -eq [IP] | select OwningProcess | Pause-Process
```


## Special Scenarios
Note: all of the pause/unpause examples above will work with these special cases. 
(FYI: the line between "Scenarios" and "Special Scenarios" is fairly arbitrary.)

### Special Scenario 1: 
You want to pause process ID 1337 for only 30 seconds, and then have it resume.

``` 
Pause-Process -ID 1337; sleep 30; UnPause-Process 1337
``` 


## Authors

* **Mick Douglas** - *Initial release* - @BetterSafetyNet

## License

This project is licensed under the Creative Commons Attribution License https://creativecommons.org/licenses/by/4.0/


## TODOs & Requests for help
Here's my TODO list.  I'll work on them... but if you beat me to it, you'll get full credit.  Bottom line, I'd love assistance of any sort on this project.  

* Make a function that checks to see if a debug has already been attached to a specific process.

* Create a test/check to see if the user running the script has debug permissions.

* Make this tool work with PowerShell's ScheduleJob or ScheduleTask.  The problem I've always run into is making the script work in default PowerShell sessions.  Yes, I know you can permanently install a module.  Is there a way to avoid this?  Using sleep commands with a ";" command separator (see Special Scenario 1) feels... awkward.  (it totally works though!!)
 

## Help Requests:
I sure could use your help! From code, to documentation, to testing, there's something you can do to help.  You, yes you! I need ** YOUR ** help!

* Does this tool work on your system?  Do each of the scenarios work as expected?

* Do you have a scenario I've not listed?  Is there something else I should cover?

* What additional documentation is needed?

* Are there other features you'd like to see?

* If there's a better way of organizing the scenarios please let me know.


## Acknowledgments

* Thanks Dave Kennedy for pointing me to the API (via a stackoverflow article no less!)
* Matt Graeber for tipping me off to how easy DLL imports actually were
* Adam Crompton for initial testing, encouragement, and feature suggestions
* Ed Skoudis for feature suggestions
* Rob Fuller for suggesting that I buckle down and make this readme! 
* My wife, for tolerating my obsessive coding on this.
