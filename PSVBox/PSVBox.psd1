@{

RootModule = 'PSVBox'
ModuleVersion = '0.0.0.180430'
GUID = 'efb6c648-83e7-48bd-8cea-7f7eafef03b2'
Author = 'Masatoshi Higuchi'
CompanyName = 'N/A'
Copyright = '(c) 2018 Masatoshi Higuchi. All rights reserved.'
Description = 'Controlling VirtualBox with PowerShell'

FunctionsToExport = @(
	'Get-Machine'
	'New-Machine', 'Remove-Machine'
	'Start-Machine', 'Stop-Machine'
	'Get-HardDisk'
	'New-HardDisk', 'Remove-HardDisk'
)
CmdletsToExport = @()
VariablesToExport = @()
AliasesToExport = @()

PrivateData = @{ PSData = @{
	Tags = @('VirtualBox', 'COM')
	LicenseUri = 'https://raw.githubusercontent.com/matt9ucci/PSVBox/master/LICENSE'
	ProjectUri = 'https://github.com/matt9ucci/PSVBox'
} }

}
