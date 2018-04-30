enum AccessMode {
	ReadOnly  = 1
	ReadWrite = 2
}

enum DeviceType {
	Null         = 0
	Floppy       = 1
	DVD          = 2
	HardDisk     = 3
	Network      = 4
	USB          = 5
	SharedFolder = 6
	Graphics3D   = 7
}

enum LockType {
	Null   = 0
	Shared = 1
	Write  = 2
	VM     = 3
}

enum MachineState {
	Null                   =  0
	PoweredOff             =  1
	Saved                  =  2
	Teleported             =  3
	Aborted                =  4
	Running                =  5
	Paused                 =  6
	Stuck                  =  7
	Teleporting            =  8
	LiveSnapshotting       =  9
	Starting               = 10
	Stopping               = 11
	Saving                 = 12
	Restoring              = 13
	TeleportingPausedVM    = 14
	TeleportingIn          = 15
	FaultTolerantSyncing   = 16
	DeletingSnapshotOnline = 17
	DeletingSnapshotPaused = 18
	OnlineSnapshotting     = 19
	RestoringSnapshot      = 20
	DeletingSnapshot       = 21
	SettingUp              = 22
	Snapshotting           = 23
}

enum MachineStatePseudo {
	FirstOnline            =  5
	LastOnline             = 19
	FirstTransient         =  8
	LastTransient          = 23
}

enum MediumVariant {
	Standard            =          0
	VmdkSplit2G         =       0x01
	VmdkRawDisk         =       0x02
	VmdkStreamOptimized =       0x04
	VmdkESX             =       0x08
	VdiZeroExpand       =      0x100
	Fixed               =    0x10000
	Diff                =    0x20000
	NoCreateDir         = 0x40000000
}

enum SessionState {
	Null      = 0
	Unlocked  = 1
	Locked    = 2
	Spawning  = 3
	Unlocking = 4
}
