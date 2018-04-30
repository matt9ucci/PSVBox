$uri = 'https://www.virtualbox.org/svn/vbox/trunk/src/VBox/Main/idl/VirtualBox.xidl'
$outFileDir = "$PSScriptRoot\..\Temp"
$outFileName = Split-Path $Uri -Leaf

New-Item $outFileDir -ItemType Directory -Force > $null

Invoke-WebRequest -Uri $uri -OutFile (Join-Path $outFileDir $outFileName) -Verbose
