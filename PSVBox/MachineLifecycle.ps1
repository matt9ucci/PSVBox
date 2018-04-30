<#
.EXAMPLE
	Start-Machine ubuntu-16.04.4
.EXAMPLE
	Start-Machine ubuntu-16.04.4 -Frontend headless
.EXAMPLE
	Start-Machine alpine-*, debian-*
#>
function Start-Machine {
	Param(
		[SupportsWildcards()]
		[Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = "Machine name")]
		[string[]]$Name,
		[ValidateSet('emergencystop', 'gui', 'headless', 'sdl')]
		[string]$Frontend
	)

	Process {
		$machines = Get-Machine $Name
		foreach ($m in $machines) {
			if ($m.State -ge [MachineStatePseudo]::FirstOnline -and
			    $m.State -le [MachineStatePseudo]::LastOnline) {
				Write-Warning ('{0} is in online state: {1}' -f $m.Name, [MachineState]$m.State)
				continue
			}

			$session = New-Object -ComObject VirtualBox.Session
			$progress = $m.LaunchVMProcess($session, $Frontend, $null)
			Write-Verbose $progress.OperationDescription
			$progress.waitForCompletion(-1)
			Write-Verbose ('{0}: ResultCode = {1}' -f $progress.Description, $progress.ResultCode)
		}
	}
}

<#
.EXAMPLE
	Stop-Machine ubuntu-16.04.4
.EXAMPLE
	Stop-Machine alpine-*, debian-*
#>
function Stop-Machine {
	Param(
		[SupportsWildcards()]
		[Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = "Machine name")]
		[string[]]$Name
	)

	Process {
		$machines = Get-Machine $Name
		foreach ($m in $machines) {
			try {
				$session = New-Object -ComObject VirtualBox.Session
				$m.LockMachine($session, [LockType]::Shared)
				if ($m.State -notin @([MachineState]::Running, [MachineState]::Paused, [MachineState]::Stuck)) {
					Write-Warning ('{0} is in unstoppable state: {1}' -f $m.Name, [MachineState]$m.State)
					continue
				}

				if ($session.Console.getGuestEnteredACPIMode()) {
					$session.Console.PowerButton()
				} else {
					$progress = $session.Console.PowerDown()
					Write-Verbose $progress.OperationDescription
					$progress.waitForCompletion(-1)
					Write-Verbose ('{0}: ResultCode = {1}' -f $progress.Description, $progress.ResultCode)
				}
			} finally {
				if ($session.State -eq [SessionState]::Locked) { $session.UnlockMachine() }
			}
		}
	}
}
