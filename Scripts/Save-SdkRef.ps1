Param(
	[string]$Version
)

if ($Version) {
	$uri = 'http://download.virtualbox.org/virtualbox/{0}/SDKRef.pdf' -f $Version
} else {
	$uri = 'http://download.virtualbox.org/virtualbox/SDKRef.pdf'
}
$outFileDir = "$PSScriptRoot\..\References"
$outFileName = Split-Path $Uri -Leaf

New-Item $outFileDir -ItemType Directory -Force > $null

Invoke-WebRequest -Uri $uri -OutFile (Join-Path $outFileDir $outFileName) -Verbose
