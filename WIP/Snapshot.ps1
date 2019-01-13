function Restore-Snapshot {
	param (
		[Parameter(Mandatory = $true)]
		[string]$VmName,
		[Parameter(Mandatory = $true)]
		[string]$SnapshotName
	)

	$session = New-Object -ComObject VirtualBox.Session

	($vbox.FindMachine($VmName)).LockMachine($session, [LockType]::Write)

	$machine = $session.Machine
	$snapshot = $machine.FindSnapshot($SnapshotName)
	$progress = $machine.RestoreSnapshot($snapshot)
	$progress.WaitForCompletion(20000)

	$session.UnlockMachine()
}
