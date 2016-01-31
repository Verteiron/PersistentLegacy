Scriptname vDBM__MetaQuestScript extends Quest
{Do initialization and track variables for scripts.}

;=== Imports ===--

Import Utility
Import Game

;=== Properties ===--

Actor Property PlayerRef Auto

Bool Property Ready = False Auto

Float Property ModVersion Auto Hidden
Int Property ModVersionInt Auto Hidden

Int Property ModVersionMajor Auto Hidden
Int Property ModVersionMinor Auto Hidden
Int Property ModVersionPatch Auto Hidden

String Property ModName = "Persistent Legacy" Auto Hidden

;=== Script properties ===--

vDBM_DataManager Property DataManager Auto

;=== Config variables ===--

;=== Variables ===--

Float _CurrentVersion
Int _iCurrentVersion
String _sCurrentVersion

Bool _ShowedSKSEWarning = False
Bool _Running
Bool _bVersionSystemUpdated = False

;=== Events ===--

Event OnInit()
	DebugTrace("Metaquest event: OnInit - IsRunning: " + IsRunning() + " ModVersion: " + ModVersion + " ModVersionMajor: " + ModVersionMajor)
	If IsRunning() && ModVersion == 0 && !ModVersionMajor
		RegisterForSingleUpdate(2)
	EndIf
EndEvent

Event OnReset()
	;DebugTrace("Metaquest event: OnReset")
EndEvent

Event OnUpdate()
	DoUpkeep(True)
EndEvent

Event OnGameReload()
	DebugTrace("Metaquest event: OnGameReload")
	;If vDBM_CFG_Shutdown.GetValue() != 0
		DoUpkeep(False)
	;EndIf
EndEvent

Event OnShutdown(string eventName, string strArg, float numArg, Form sender)
	DebugTrace("OnShutdown!")
	Wait(0.1)
	DoShutdown()
EndEvent

;=== Functions ===--

Function DoUpkeep(Bool DelayedStart = True)
	DebugTrace("Metaquest event: DoUpkeep(" + DelayedStart + ")")
	;FIXME: CHANGE THIS WHEN UPDATING!
	ModVersionMajor = 0
	ModVersionMinor = 8
	ModVersionPatch = 0
	If !CheckDependencies()
		AbortStartup()
		Return
	EndIf
	_iCurrentVersion = GetVersionInt(ModVersionMajor,ModVersionMinor,ModVersionPatch)
	_sCurrentVersion = GetVersionString(_iCurrentVersion)
	String sModVersion = GetVersionString(ModVersion as Int)
	Ready = False
	If DelayedStart
		Wait(RandomFloat(3,5))
	EndIf
	
	String sErrorMessage
	DebugTrace("" + ModName)
	DebugTrace("Performing upkeep...")
	DebugTrace("Loaded version is " + sModVersion + ", Current version is " + _sCurrentVersion)
	If ModVersion == 0
		DebugTrace("Newly installed, doing initialization...")
		DoInit()
		If ModVersion == _iCurrentVersion
			DebugTrace("Initialization succeeded.")
		Else
			DebugTrace("WARNING! Initialization had a problem!")
		EndIf
	ElseIf ModVersion < _iCurrentVersion
		DebugTrace("Installed version is older. Starting the upgrade...")
		DoUpgrade()
		If ModVersion != _iCurrentVersion
			DebugTrace("WARNING! Upgrade failed!")
			Debug.MessageBox("WARNING! " + ModName + " upgrade failed for some reason. You should report this to the mod author.")
		EndIf
		DebugTrace("Upgraded to " + GetVersionString(_iCurrentVersion))
	Else
		;FIXME: Do init stuff in other quests
		DebugTrace("Loaded, no updates.")
	EndIf
	DataManager.SetDisplaysActive()
	DebugTrace("Upkeep complete!")
	Ready = True

EndFunction

Function DoInit()
	_Running = True
	ModVersion = _iCurrentVersion
	DataManager.DoFirstLoadScan()
EndFunction

Function DoUpgrade()
	_Running = False
	;version-specific upgrade code
	
	; If ModVersion < GetVersionInt(1,1,2)
	; 	Debug.Trace("vDBM/Upgrade/1.1.2: Upgrading to 1.1.2...")
	; 	Debug.Trace("vDBM/Upgrade/1.1.2: Upgrade to 1.1.2 complete!")
	; 	ModVersion = GetVersionInt(1,1,2)
	; EndIf
	
	;Generic upgrade code
	If ModVersion < _iCurrentVersion
		DebugTrace("Upgrading to " + GetVersionString(_iCurrentVersion) + "...")
		;FIXME: Do upgrade stuff!
		ModVersion = _iCurrentVersion
		DebugTrace("Upgrade to " + GetVersionString(_iCurrentVersion) + " complete!")
	EndIf
	_Running = True
	DebugTrace("Upgrade complete!")
EndFunction

Function AbortStartup(String asAbortReason = "None specified")
	DebugTrace("Aborting startup! Reason: " + asAbortReason,2)
	Ready = False

	_Running = False
	Ready = True
	Stop()
EndFunction

Function DoShutdown(Bool abClearData = False)
	Ready = False
	DebugTrace("Shutting down!")
	_iCurrentVersion = 0
	ModVersion = 0
	
	_Running = False
	Ready = True
EndFunction

Bool Function CheckDependencies()
	Float fSKSE = SKSE.GetVersion() + SKSE.GetVersionMinor() * 0.01 + SKSE.GetVersionBeta() * 0.0001
	DebugTrace("SKSE is version " + fSKSE)
	DebugTrace("DBM_Utils is version " + SKSE.GetPluginVersion("DBM_Utils"))
	;Debug.MessageBox("SKSE version is " + fSKSE)
	If fSKSE < 1.0702
		Debug.MessageBox("SuperStash\nThis mod requires SKSE 1.7.2 or higher, but it seems to be missing or out of date.\nThe mod will now shut down.")
		Return False
	Else
		;Proceed
	EndIf

	Return True
EndFunction

Int Function GetVersionInt(Int iMajor, Int iMinor, Int iPatch)
	Return Math.LeftShift(iMajor,16) + Math.LeftShift(iMinor,8) + iPatch
EndFunction

String Function GetVersionString(Int iVersion)
	Int iMajor = Math.RightShift(iVersion,16)
	Int iMinor = Math.LogicalAnd(Math.RightShift(iVersion,8),0xff)
	Int iPatch = Math.LogicalAnd(iVersion,0xff)
	String sMajorZero
	String sMinorZero
	String sPatchZero
	If !iMajor
		sMajorZero = "0"
	EndIf
	If !iMinor
		sMinorZero = "0"
	EndIf
	;If !iPatch
		;sPatchZero = "0"
	;EndIf
	;DebugTrace("Got version " + iVersion + ", returning " + sMajorZero + iMajor + "." + sMinorZero + iMinor + "." + sPatchZero + iPatch)
	Return sMajorZero + iMajor + "." + sMinorZero + iMinor + "." + sPatchZero + iPatch
EndFunction

Function DebugTrace(String sDebugString, Int iSeverity = 0)
	Debug.Trace("vDBM/MetaQuest: " + sDebugString,iSeverity)
EndFunction
