<#
.EXAMPLE
	Get-HostNetworkInterface "VirtualBox Host-Only Ethernet Adapter"
.EXAMPLE
	Get-HostNetworkInterface VirtualBox*, *Host-Only*
.EXAMPLE
	Get-HostNetworkInterface -Id 83d9bbb3-ed37-475b-8750-168de80bb8a5
#>
function Get-HostNetworkInterface {
	[CmdletBinding(DefaultParameterSetName = 'Name')]
	param (
		[SupportsWildcards()]
		[Parameter(ParameterSetName = 'Name', Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = "Host network interface name")]
		[string[]]$Name = '*',
		[SupportsWildcards()]
		[Parameter(ParameterSetName = 'Id', ValueFromPipelineByPropertyName, HelpMessage = "Host network interface ID")]
		[string[]]$Id = '*',
		[Parameter(HelpMessage = "Host network interface type")]
		[HostNetworkInterfaceType[]]$InterfaceType,
		[Parameter(HelpMessage = "Host network interface medium type")]
		[HostNetworkInterfaceMediumType[]]$MediumType,
		[Parameter(HelpMessage = "Host network interface status")]
		[HostNetworkInterfaceStatus[]]$Status
	)

	process {
		$ifs = switch ($PSCmdlet.ParameterSetName) {
			Name { $Name | % { $vbox.Host.NetworkInterfaces | ? Name -In (Resolve-HostNetworkInterfaceName $_) } }
			Id   { $Id   | % { $vbox.Host.NetworkInterfaces | ? Id   -In (Resolve-HostNetworkInterfaceId $_) } }
		}

		if ($InterfaceType.Count) {
			$ifs = $ifs | ? InterfaceType -In $InterfaceType
		}

		if ($MediumType.Count) {
			$ifs = $ifs | ? MediumType -In $MediumType
		}

		if ($Status.Count) {
			$ifs = $ifs | ? Status -In $Status
		}

		$ifs
	}
}

function Resolve-HostNetworkInterfaceName {
	param (
		[SupportsWildcards()]
		[Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = "Host network interface name")]
		[string[]]$Name
	)

	process {
		$Name | % { $vbox.Host.NetworkInterfaces.Name -like $_ }
	}
}

function Resolve-HostNetworkInterfaceId {
	param (
		[SupportsWildcards()]
		[Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = "Host network interface ID")]
		[string[]]$Id
	)

	process {
		$Id | % { $vbox.Host.NetworkInterfaces.Id -like $_ }
	}
}
