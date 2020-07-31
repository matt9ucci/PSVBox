$projectRoot = Join-Path $PSScriptRoot .. ..
Import-Module (Join-Path $projectRoot PSVBox) -Force

Describe "New-Machine" {
	It "returns a default machine" {
		$m = New-Machine default
		$m.Name | Should Be 'default'
		$m.Groups | Should Be '/'
		$m.OSTypeId | Should Be 'Other'
	}

	It "returns a custom machine" {
		$m = New-Machine -Name custom -OSTypeId Ubuntu_64 -MemorySize 4GB -VRAMSize 12MB
		$m.Name | Should Be 'custom'
		$m.OSTypeId | Should Be 'Ubuntu_64'
		$m.MemorySize | Should Be 4096
		$vramSize = $m.VRAMSize ? $m.VRAMSize : $m.GraphicsAdapter.VRAMSize
		$vramSize | Should Be 12
	}
}

Describe "Add-StorageController" {
	$m = New-Machine -Name test

	It "adds IDE" {
		$m | Add-StorageController -Name testIDE -StorageBus IDE
		$sc = $m.StorageControllers[0]
		$sc.Name | Should Be 'testIDE'
		$sc.Bus | Should Be 1
	}
	It "adds SATA" {
		$m | Add-StorageController -Name testSATA -StorageBus SATA
		$sc = $m.StorageControllers[1]
		$sc.Name | Should Be 'testSATA'
		$sc.Bus | Should Be 2
	}
}

Describe "Unregister-Machine" {
	$m = New-Machine -Name test

	It "will remove a registered machine" {
		$m | Register-Machine
		(Get-Machine test).Name | Should Be test
	}

	It "removes a registered machine" {
		$m | Unregister-Machine
		Get-Machine test | Should BeNullOrEmpty
	}
}
