function New-SharedFolder {
	Param(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		$Machine,
		[string]$Name = (Split-Path -Path $HostPath -Leaf),
		[Parameter(Mandatory = $true)]
		[string]$Path,
		[bool]$Writable,
		[bool]$AutoMount
	)
	$PSBoundParameters
	$Name
	#	$Machine.CreateSharedFolder($Name, $HostPath, $Writable, $AutoMount)
}


# Add-SharedFolder($m, "Shared", "C:\Users\matt\Downloads", $true, $true)
#$vbox.FindMachine('mate') | New-SharedFolder -HostPath $DOWNLOADS


#New-Machine -Name 'test170726' -OsTypeId 'Ubuntu_64' -Register

#sleep 3

#$vbox.FindMachine('test170726') | Unregister-Machine
$vbox.FindMachine('testaaaaaa') | Unregister-Machine

