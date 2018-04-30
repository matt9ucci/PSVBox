function Test-Alias ([string]$Alias, [string]$Command) {
	if ((Get-Alias $Alias).ResolvedCommand -ne (Get-Command $Command)) {
		throw "Unexpected alias: '{0}' should be an alias for {1}" -f $Alias, $Command
	}
}
Test-Alias % ForEach-Object
Test-Alias '`?' Where-Object

$vbox = New-Object -ComObject VirtualBox.VirtualBox

. $PSScriptRoot\Enum.ps1
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
