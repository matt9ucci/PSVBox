Param(
	[string]$Version
)

if ($Version) {
	$uri = 'https://download.virtualbox.org/virtualbox/{0}/UserManual.pdf' -f $Version
} else {
	$uri = 'https://download.virtualbox.org/virtualbox/UserManual.pdf'
}

$outFileDir = "$PSScriptRoot\..\References"
$outFileName = Split-Path $Uri -Leaf

New-Item $outFileDir -ItemType Directory -Force > $null

Invoke-WebRequest -Uri $uri -OutFile (Join-Path $outFileDir $outFileName) -Verbose
