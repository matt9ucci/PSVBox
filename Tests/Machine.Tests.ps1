Import-Module "$PSScriptRoot\..\PSVBox" -Force

Describe "New/Get/Remove Ubuntu_64 machine" {
	$name = 'Ubuntu64Pester'
	$osTypeId = 'Ubuntu_64'

	$new = New-Machine $name -OsTypeId $osTypeId
	It "creates a new machine" {
		$new.Name | Should Be $name
		$new.OsTypeId | Should Be $osTypeId
	}

	$get = Get-Machine $new.Name
	It "returns it" {
		$get.Name | Should Be $name
		$get.OsTypeId | Should Be $osTypeId
	}

	Remove-Machine $new.Id
	$remove = Get-Machine $new.Id
	It "deletes it" {
		$remove | Should BeNullOrEmpty
	}
}
