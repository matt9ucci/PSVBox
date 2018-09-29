param (
	[string]$Version,
	[ValidateSet('MD5', 'SHA256')]
	[string]$Algorithm = 'SHA256'
)

Import-Module $PSScriptRoot\..\PSVBox\PSVBox -Force -Scope Local

if (!$Version) { $Version = Get-LatestVersion }
$uri = "https://download.virtualbox.org/virtualbox/${Version}/${Algorithm}SUMS"
$outFileDir = "$PSScriptRoot\..\Temp"
$outFileName = Split-Path $uri -Leaf

New-Item $outFileDir -ItemType Directory -Force > $null
Invoke-WebRequest $uri -OutFile (Join-Path $outFileDir $outFileName) -Verbose
