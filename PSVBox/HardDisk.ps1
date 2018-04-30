<#
.EXAMPLE
	Get-HardDisk ubuntu-16.04.4.vmdk
.EXAMPLE
	Get-HardDisk alpine-*, debian-*
.EXAMPLE
	Get-HardDisk -Id 83d9bbb3-ed37-475b-8750-168de80bb8a5
#>
function Get-HardDisk {
	[CmdletBinding(DefaultParameterSetName = 'Name')]
	Param(
		[SupportsWildcards()]
		[Parameter(ParameterSetName = 'Name', Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = "Hard disk name")]
		[string[]]$Name = '*',
		[SupportsWildcards()]
		[Parameter(ParameterSetName = 'Id', ValueFromPipelineByPropertyName, HelpMessage = "Hard disk ID")]
		[string[]]$Id = '*'
	)

	Process {
		switch ($PSCmdlet.ParameterSetName) {
			Name { $Name | % { $vbox.HardDisks | ? Name -In (Resolve-HardDiskName $_) } }
			Id   { $Id   | % { $vbox.HardDisks | ? Id   -In (Resolve-HardDiskId $_) } }
		}
	}
}

function Resolve-HardDiskName {
	Param(
		[SupportsWildcards()]
		[Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = "Hard disk name")]
		[string[]]$Name
	)

	Process {
		$Name | % { $vbox.HardDisks.Name -like $_ }
	}
}

function Resolve-HardDiskId {
	Param(
		[SupportsWildcards()]
		[Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = "Hard disk ID")]
		[string[]]$Id
	)

	Process {
		$Id | % { $vbox.HardDisks.Id -like $_ }
	}
}
