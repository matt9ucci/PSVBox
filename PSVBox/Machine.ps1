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
		[Parameter(ParameterSetName = 'Id', ValueFromPipelineByPropertyName, HelpMessage = "Machine ID")]
		[string[]]$Id = '*',
		[Parameter(HelpMessage = "Machine state")]
		[MachineState[]]$State
	)

	Process {
		$machines = switch ($PSCmdlet.ParameterSetName) {
			Name { $Name | % { $vbox.Machines | ? Name -In (Resolve-MachineName $_) } }
			Id   { $Id   | % { $vbox.Machines | ? Id   -In (Resolve-MachineId $_) } }
		}

		if ($State) {
			$machines = $machines | ? State -In $State
		}

		$machines
	}
}

function Resolve-MachineName {
	Param(
		[SupportsWildcards()]
		[Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = "Machine name")]
		[string[]]$Name
	)

	Process {
		$Name | % { $vbox.Machines.Name -like $_ }
	}
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
