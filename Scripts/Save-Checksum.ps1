param (
	[string]
	$Version,

	[ValidateSet('MD5', 'SHA256')]
	[string]
	$Algorithm = 'SHA256'
)

# Do not `ipmo PSVBox.psm1` because it throws an error if VirtualBox is not installed yet
Import-Module $PSScriptRoot\..\PSVBox\Download.ps1 -Force -Scope Local

if (!$Version) { $Version = Get-LatestVersion }
$uri = "https://download.virtualbox.org/virtualbox/${Version}/${Algorithm}SUMS"
$outFileDir = "$PSScriptRoot\..\Temp"
$outFileName = Split-Path $uri -Leaf

New-Item $outFileDir -ItemType Directory -Force | Out-Null

$param = @{
	Uri = $uri
	OutFile = Join-Path $outFileDir $outFileName
	Verbose = $true
}
Invoke-WebRequest @param
