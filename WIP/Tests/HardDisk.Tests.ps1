$projectRoot = Join-Path $PSScriptRoot ..
Import-Module (Join-Path $projectRoot PSVBoxManage) -Force

Describe "Dynamic HD" {
	$hdPath = Join-Path $PSScriptRoot ('dynamicHD.vdi')
	$hd = New-HardDisk -Path $hdPath -Size 1GB

	It "returns a saved dynamic HD" {
		$hd.Name | Should Be dynamicHD.vdi
		$hd.Size | Should BeLessThan 1GB
		$hd.Format | Should Be VDI
		$hd.Variant -contains 0 | Should Be $true
	}

	It "gets the HD" {
		(Get-HardDisk -Path $hdPath).Location | Should Exist
	}

	It "removes the HD" {
		Remove-HardDisk -Path $hdPath
		$hdPath | Should Not Exist
	}
}

Describe "Fixed HD" {
	$hdPath = Join-Path $PSScriptRoot ('fixedHD.vmdk')
	$hd = New-HardDisk -Path $hdPath -Size 1MB -Format VMDK -MediumVariant Fixed

	It "returns a saved fixed HD" {
		$hdPath | Should Exist
		$hd.Name | Should Be fixedHD.vmdk
		$hd.Size | Should BeLessThan 1GB
		$hd.Format | Should Be VMDK
		$hd.Variant -contains 0x10000 | Should Be $true
	}

	It "gets the HD" {
		(Get-HardDisk -Path $hdPath).Location | Should Exist
	}

	It "removes the HD" {
		Remove-HardDisk -Path $hdPath
		$hdPath | Should Not Exist
	}
}
