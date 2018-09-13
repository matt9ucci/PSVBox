param (
	[string]$Version,
	[ValidateSet('MD5', 'SHA256')]
	[string]$Algorithm = 'SHA256'
)

Import-Module $PSScriptRoot\..\PSVBox\PSVBox -Force -Scope Local

if (!$Version) { $Version = Get-LatestVersion }
$uri = 'https://download.virtualbox.org/virtualbox/{0}/{1}SUMS' -f $Version, $Algorithm

$outFileDir = "$PSScriptRoot\..\Temp"
$outFileName = Split-Path $Uri -Leaf

New-Item $outFileDir -ItemType Directory -Force > $null

Invoke-WebRequest -Uri $uri -OutFile (Join-Path $outFileDir $outFileName) -Verbose
