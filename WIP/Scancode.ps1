Add-Type -AssemblyName WindowsBase

<#
.SYNOPSIS
A wrapper for Windows API keyboard input functions.

.LINK
Keyboard Input: https://msdn.microsoft.com/en-us/library/windows/desktop/ms645530(v=vs.85).aspx
#>
Add-Type -Namespace "WINAPI" -Name "KeyboardInput" -MemberDefinition @"
public const uint MAPVK_VK_TO_CHAR = 2;
public const uint MAPVK_VK_TO_VSC = 0;
public const uint MAPVK_VK_TO_VSC_EX = 4;
public const uint MAPVK_VSC_TO_VK = 1;
public const uint MAPVK_VSC_TO_VK_EX = 3;

// https://msdn.microsoft.com/en-us/library/windows/desktop/ms646296(v=vs.85).aspx
[DllImport("user32.dll")]
public static extern IntPtr GetKeyboardLayout(int idThread);

// https://msdn.microsoft.com/en-us/library/windows/desktop/ms646307(v=vs.85).aspx
[DllImport("user32.dll")]
public static extern uint MapVirtualKeyEx(uint uCode, uint uMapType, IntPtr dwhkl);

// https://msdn.microsoft.com/en-us/library/windows/desktop/ms646332(v=vs.85).aspx
[DllImport("user32.dll")]
public static extern short VkKeyScanEx(char ch, IntPtr dwhkl);
"@

function ConvertTo-VirtualKeyCode {
	Param(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[char]$Character,
		[System.IntPtr]$KeyboardLayout = [WINAPI.KeyboardInput]::GetKeyboardLayout(0)
	)

	Process {
		$vk = [System.BitConverter]::GetBytes([WINAPI.KeyboardInput]::VkKeyScanEx($Character, $KeyboardLayout))

		# shift state
		switch ($vk[1]) {
			0 {} # no key is pressed
			1 { [System.Windows.Input.KeyInterop]::VirtualKeyFromKey([System.Windows.Input.Key]::LeftShift) }
			2 { [System.Windows.Input.KeyInterop]::VirtualKeyFromKey([System.Windows.Input.Key]::LeftCtrl) }
			4 { [System.Windows.Input.KeyInterop]::VirtualKeyFromKey([System.Windows.Input.Key]::LeftAlt) }
			Default {}
		}

		# virtual-key code
		$vk[0]
	}
}

function ConvertTo-Scancode {
	Param(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[byte]$VirtualKeyCode,
		[System.IntPtr]$KeyboardLayout = [WINAPI.KeyboardInput]::GetKeyboardLayout(0),
		[Parameter(ParameterSetName = 'Break')]
		[switch]$Break
	)

	Begin {
		# Break Code = Make Code + 0x80
		$adding = 0x80 * $Break.IsPresent
	}

	Process {
		[WINAPI.KeyboardInput]::MapVirtualKeyEx($VirtualKeyCode, [WINAPI.KeyboardInput]::MAPVK_VK_TO_VSC_EX, $KeyboardLayout) + $adding
	}
}

function Send-Scancode {
	Param(
		[Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[Alias('Id')]
		[string]$Name,
		[Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[int[]]$Scancode
	)

	Begin {
		$session = New-Object -ComObject "VirtualBox.Session"
		$m = Get-Machine $Name
		$m.LockMachine($session, [LockType]::Shared)
	}

	Process {
		$session.Console.Keyboard.PutScancodes($Scancode) > $null
	}

	End {
		$session.UnlockMachine()
	}
}
