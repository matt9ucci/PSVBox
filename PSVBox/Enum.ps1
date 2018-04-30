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

enum SessionState {
	Null      = 0
	Unlocked  = 1
	Locked    = 2
	Spawning  = 3
	Unlocking = 4
}
