$outFile = "$PSScriptRoot\..\Temp\Enum.ps1"
[xml]$xidl = Get-Content "$PSScriptRoot\..\Temp\VirtualBox.xidl"

foreach ($e in $xidl.GetElementsByTagName('enum')) {
	$consts = $e.GetElementsByTagName('const')
	$namePad = ($consts.name | Measure-Object Length -Maximum).Maximum
	$valuePad = ($consts.value | Measure-Object Length -Maximum).Maximum

	$keyValues = New-Object System.Collections.ArrayList
	foreach ($c in $consts) {
		$keyValues.Add(("{0} = {1}" -f $c.name.PadRight($namePad), $c.value.PadLeft($valuePad))) > $null
	}

@"
enum $($e.name) {
	$($keyValues -join "`n`t")
}

"@ | Out-File $outFile -Append
}
