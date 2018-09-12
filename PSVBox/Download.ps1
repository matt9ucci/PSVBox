function Get-LatestVersion {
	param (
		[ValidateSet('Beta', 'Stable')]
		[string]$Release
	)

	$r = switch ($Release) {
		Beta { '-BETA' }
		Stable { '-STABLE' }
		Default { '' }
	}
	$uri = "https://download.virtualbox.org/virtualbox/LATEST${r}.TXT"
	(Invoke-WebRequest $uri).Content.Trim()
}
