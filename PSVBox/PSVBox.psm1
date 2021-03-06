function Test-Alias ([string]$Alias, [string]$Command) {
	if ((Get-Alias $Alias).ResolvedCommand -ne (Get-Command $Command)) {
		throw "Unexpected alias: '{0}' should be an alias for {1}" -f $Alias, $Command
	}
}
Test-Alias % ForEach-Object
Test-Alias '`?' Where-Object

$vbox = New-Object -ComObject VirtualBox.VirtualBox
$vboxVersion = $vbox.Version -split '\.' # e.g. @(6, 1, 0_RC1)

. $PSScriptRoot\Download.ps1
. $PSScriptRoot\Enum.ps1
. $PSScriptRoot\HardDisk.ps1
. $PSScriptRoot\Host.ps1
. $PSScriptRoot\Machine.ps1
. $PSScriptRoot\MachineLifecycle.ps1

# Release COM object immediately when invoking Remove-Module cmdlet
$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = {
	[System.Runtime.InteropServices.Marshal]::ReleaseComObject($vbox) > $null
	[System.GC]::Collect()
}

$commandNames = (Get-Command -Module PSVBox -Name *-Machine).Name
Register-ArgumentCompleter -ParameterName Name -CommandName $commandNames -ScriptBlock {
	Param($commandName, $parameterName, $wordToComplete)
	(Get-Machine "$wordToComplete*").Name | Sort-Object -Unique
}
Register-ArgumentCompleter -ParameterName Group -CommandName $commandNames -ScriptBlock {
	Param($commandName, $parameterName, $wordToComplete)
	@($vbox.MachineGroups) -like "$wordToComplete*" | Sort-Object -Unique
}

$commandNames = (Get-Command -Module PSVBox -Name *-HardDisk).Name
Register-ArgumentCompleter -ParameterName Name -CommandName $commandNames -ScriptBlock {
	Param($commandName, $parameterName, $wordToComplete)
	(Get-HardDisk "$wordToComplete*").Name | Sort-Object -Unique
}

$commandNames = (Get-Command -Module PSVBox -Name *-HostNetworkInterface).Name
Register-ArgumentCompleter -ParameterName Name -CommandName $commandNames -ScriptBlock {
	Param($commandName, $parameterName, $wordToComplete)
	(Get-HostNetworkInterface "$wordToComplete*").Name | Sort-Object -Unique | % { "'{0}'" -f $_ }
}
