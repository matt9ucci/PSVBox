<#
.EXAMPLE
	Get-Machine ubuntu-16.04.4
.EXAMPLE
	Get-Machine alpine-*, debian-*
.EXAMPLE
	Get-Machine -Id 84c46895-91b7-4671-b6e7-6065dd8983d9
#>
function Get-Machine {
	[CmdletBinding(DefaultParameterSetName = 'Name')]
	Param(
		[SupportsWildcards()]
		[Parameter(ParameterSetName = 'Name', Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = "Machine name")]
		[string[]]$Name = '*',
		[SupportsWildcards()]
		[Parameter(ParameterSetName = 'Name', Position = 1, HelpMessage = "Machine group")]
		[string[]]$Group = '/',
		[SupportsWildcards()]
		[Parameter(ParameterSetName = 'Id', ValueFromPipelineByPropertyName, HelpMessage = "Machine ID")]
		[string[]]$Id = '*',
		[Parameter(HelpMessage = "Machine state")]
		[MachineState[]]$State
	)

	Process {
		$machines = switch ($PSCmdlet.ParameterSetName) {
			Name { $vbox.Machines | MachineByName $Name | MachineByGroup $Group }
			Id { $Id | % { $vbox.Machines | ? Id -In (Resolve-MachineId $_) } }
		}

		if ($State) {
			$machines = $machines | ? State -In $State
		}

		$machines
	}
}

<#
.EXAMPLE
	$ubuntu = @{
		Name = 'ubuntu-16.04.4'
		OsTypeId = 'Ubuntu_64'
		MemorySize = 2GB
		HardDiskFormat = 'VMDK'
		HardDiskSize = 32GB
		DvdPath = Join-Path $HOME ubuntu-16.04.4-server-amd64.iso
		Description = 'Ubuntu example'
	}
	New-Machine @ubuntu -Verbose
#>
function New-Machine {
	[CmdletBinding()]
	Param(
		[Parameter(Mandatory, Position = 0, HelpMessage = "Machine ID")]
		[string]$Name,
		[string]$OsTypeId,
		[string[]]$Groups = '/',
		[Parameter(HelpMessage = "System memory size in bytes (eg. 1GB)")]
		[uint64]$MemorySize,
		[Parameter(HelpMessage = "Video memory size in bytes (eg. 16MB)")]
		[uint64]$VRamSize,
		[Parameter(HelpMessage = "Hard disk size in bytes (eg. 10GB)")]
		[uint64]$HardDiskSize,
		[string]$HardDiskFormat = $vbox.SystemProperties.DefaultHardDiskFormat,
		[Parameter(HelpMessage = "Dvd image path")]
		[string]$DvdPath,
		[string]$Description,
		[ClipboardMode]$ClipboardMode = [ClipboardMode]::Disabled,
		[DnDMode]$DnDMode = [DnDMode]::Disabled
	)

	if (Test-Machine $Name) {
		Write-Error ('{0} already exists' -f $Name)
		return
	}

	$m = $vbox.CreateMachine($null, $Name, $Groups, $OsTypeId, $null)

	$osType = $vbox.GetGuestOSType($m.OSTypeId)

	$m.MemorySize = if ($MemorySize) { [uint32]($MemorySize / 1MB) } else { $osType.RecommendedRAM }

	if ($vboxVersion[0] -ge 6 -and $vboxVersion[1] -ge 1) {
		# after version 6.1
		$m.GraphicsAdapter.VRAMSize = if ($VRamSize) { [uint32]($VRamSize / 1MB) } else { $osType.RecommendedVRAM }
	} else {
		# before version 6.1
		$m.VRAMSize = if ($VRamSize) { [uint32]($VRamSize / 1MB) } else { $osType.RecommendedVRAM }
	}

	$m.Description = if ($Description) { $Description } else { $osType.Description }

	$m.ClipboardMode = $ClipboardMode
	$m.DnDMode = $DnDMode

	# Add recommended storage controllers
	$sc = $m.addStorageController('HardDisk', $osType.RecommendedHDStorageBus)
	Write-Verbose ('Add {0} controller for hard disk' -f ([StorageBus]$sc.Bus))
	$sc = $m.addStorageController('DVD', $osType.RecommendedDVDStorageBus)
	Write-Verbose ('Add {0} controller for DVD' -f ([StorageBus]$sc.Bus))

	# Save settings file implicitly and register machine
	$vbox.RegisterMachine($m)

	# Create hard disk
	$hdParam = @{
		Path = Join-Path (Split-Path $m.SettingsFilePath) "$($m.Name).$($HardDiskFormat.ToLower())"
		Size = if ($HardDiskSize) { $HardDiskSize } else { $osType.RecommendedHDD }
		Format = $HardDiskFormat
	}
	$hd = New-HardDisk @hdParam

	# Attach hard disk to machine
	try {
		$session = New-Object -ComObject 'VirtualBox.Session'
		$m.LockMachine($session, [LockType]::Shared)
		$session.Machine.attachDevice('HardDisk', 0, 0, [DeviceType]::HardDisk, $hd)
		$session.Machine.SaveSettings()
	} finally {
		if ($session.State -eq [SessionState]::Locked) { $session.UnlockMachine() }
	}

	# Attach DVD to machine
	if ($DvdPath) {
		$dvd = $vbox.OpenMedium($DvdPath, [DeviceType]::DVD, [AccessMode]::ReadOnly, $false)
		try {
			$session = New-Object -ComObject 'VirtualBox.Session'
			$m.LockMachine($session, [LockType]::Shared)
			$session.Machine.attachDevice('DVD', 0, 0, [DeviceType]::DVD, $dvd)
			$session.Machine.SaveSettings()
		} finally {
			if ($session.State -eq [SessionState]::Locked) { $session.UnlockMachine() }
		}
	}

	$m
}

<#
.EXAMPLE
	Remove-Machine -Id (Get-Machine ubuntu-16.04.4).Id
#>
function Remove-Machine {
	Param(
		[Parameter(Mandatory, HelpMessage = "Machine ID")]
		[string]$Id
	)

	$m = $vbox.FindMachine($Id)
	$hds = $m.Unregister(([CleanupMode]::DetachAllReturnHardDisksOnly))

	# Remove *.vbox file but DeleteConfig() throws Exception
	# $progress = $m.DeleteConfig([System.MarshalByRefObject[]]$hds)
	# Write-Verbose $progress.OperationDescription
	# $progress.waitForCompletion(-1)

	# Manually remove hard disks because DeleteConfig() does not
	Remove-HardDisk -Id $hds.Id

	# Workaround: remove *.vbox file (DeleteConfig() is preferred)
	Remove-Item -Path (Split-Path $m.SettingsFilePath) -Recurse -Verbose
}

function Resolve-MachineId {
	Param(
		[SupportsWildcards()]
		[Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = "Machine ID")]
		[string[]]$Id
	)

	Process {
		$Id | % { $vbox.Machines.Id -like $_ }
	}
}

function Test-Machine {
	Param(
		[SupportsWildcards()]
		[Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = "Machine name")]
		[string[]]$Name
	)

	(Get-Machine $Name) -and $true
}

filter MachineByName([string[]]$Name) {
	foreach ($n in $Name) { if ($_.Name -like $n) { $_; return } }
}

filter MachineByGroup([string[]]$Group) {
	foreach ($g in $Group) { if ($_.Groups -like $g) { $_; return } }
}
