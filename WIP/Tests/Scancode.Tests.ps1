$projectRoot = Join-Path $PSScriptRoot ..
Import-Module (Join-Path $projectRoot PSVBoxManage) -Force

Describe "ConvertTo-VirtualKeyCode" {
	It "returns shift state and virtual-key code" {
		$vkc = 'aA;:@'.ToCharArray() | ConvertTo-VirtualKeyCode
		$vkc[0] | Should Be 65

		$vkc[1] | Should Be 160
		$vkc[2] | Should Be 65

		$vkc[3] | Should Be 186

		$vkc[4] | Should Be 160
		$vkc[5] | Should Be 186

		$vkc[6] | Should Be 160
		$vkc[7] | Should Be 50
	}
}

Describe "ConvertTo-Scancode" {
	$vkc = @(
		[System.Windows.Input.KeyInterop]::VirtualKeyFromKey([System.Windows.Input.Key]::Enter)
		[System.Windows.Input.KeyInterop]::VirtualKeyFromKey([System.Windows.Input.Key]::F6)
		[System.Windows.Input.KeyInterop]::VirtualKeyFromKey([System.Windows.Input.Key]::Escape)
	)
	It "returns shift state and virtual-key code" {
		$sc = $vkc | ConvertTo-Scancode
		$scb = $vkc | ConvertTo-Scancode -Break

		$sc[0] | Should Be 28
		$scb[0] | Should Be (28 + 0x80)

		$sc[1] | Should Be 64
		$scb[1] | Should Be (64 + 0x80)

		$sc[2] | Should Be 1
		$scb[2] | Should Be (1 + 0x80)
	}
}

# TODO Launch VM before running this test
# Describe "Send-Scancode" {
# 	It "sends scancode" {
# 		[System.Windows.Input.KeyInterop]::VirtualKeyFromKey([System.Windows.Input.Key]::Enter),
# 		[System.Windows.Input.KeyInterop]::VirtualKeyFromKey([System.Windows.Input.Key]::F6),
# 		[System.Windows.Input.KeyInterop]::VirtualKeyFromKey([System.Windows.Input.Key]::Escape) |
# 		ForEach-Object {
# 			Send-Scancode ubuntu-16.04.3 ($_ | ConvertTo-Scancode)
# 			Send-Scancode ubuntu-16.04.3 ($_ | ConvertTo-Scancode -Break)
# 			sleep -Milliseconds 50
# 		}
#
# 		'locale=en_US.UTF-8 keyboard-configuration/layoutcode=us'.ToCharArray() | ForEach-Object {
# 			$vkc = ConvertTo-VirtualKeyCode $_

# 			$scs = $vkc | ConvertTo-Scancode
# 			Send-Scancode ubuntu-16.04.3 $scs

# 			$scs = $vkc | ConvertTo-Scancode -Break
# 			[array]::Reverse($scs)
# 			Send-Scancode ubuntu-16.04.3 $scs
			
# 			sleep -Milliseconds 50
# 		}

# 		# Enter
# 		Send-Scancode ubuntu-16.04.3 @(28, (28 + 0x80))
# 	}
# }
