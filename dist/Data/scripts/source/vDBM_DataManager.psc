Scriptname vDBM_DataManager extends Quest
{Data manager script for Persistent Legacy}
;
; @author Verteiron, written for icecreamassassin
;
; === [ vDBM_DataManager.psc ] ===========================================---
; @class vDBM_DataManager
;
; Quest to automatically scan and activate (if applicable) displays at first load,
; and whenever the player loads a game. 
; ========================================================---

;=== Imports ===--

Import Utility
Import Game

;=== Properties ===--

Actor 			Property PlayerRef 				Auto

FormList 		Property DBM_DisplayLists		Auto

GlobalVariable	Property DBMV_SharingEnabled 	Auto

Int 			Property ScriptVersion 			Auto Hidden

;=== Functions ===--

Event OnInit()
	If IsRunning()
		RegisterForSingleUpdate(1)
	EndIf
EndEvent

Event OnUpdate()
	DoUpkeep()	
EndEvent

Event OnGameReload()
;Called by PlayerLoadGameAlias
	DebugTrace("OnGameReload")
	DoUpkeep()
EndEvent

Event OnDBM_Message(string eventName, string strArg, float numArg, Form sender)
	DebugTrace("Processing DBM_Message " + strArg)
	If strArg == "startSharing"
		DBMV_SharingEnabled.SetValue(1)
		DoFirstLoadScan()
		EnableActiveDisplays()
	ElseIf strArg == "stopSharing"
		DBMV_SharingEnabled.SetValue(0)
		DisableOtherDisplays()
		DBM_Utils.deleteContributor(PlayerREF.GetActorBase().GetName())
	ElseIf strArg == "doFullScan"
		DBMV_SharingEnabled.SetValue(0)
		DisableOtherDisplays()
		DoFirstLoadScan()
		If DBMV_SharingEnabled.GetValue() == 1
			EnableActiveDisplays()
		EndIf
	ElseIf strArg == "delayedTest"
		DebugTrace("starting test!")
		WaitMenuMode(3)
		TestData()
		WaitMenuMode(2)
		DebugTrace("getSharingEnabled() returns " + DBM_Utils.getSharingEnabled())
		WaitMenuMode(5)
		SendModEvent("DBM_Message","startSharing")
		WaitMenuMode(5)
		DebugTrace("getSharingEnabled() returns " + DBM_Utils.getSharingEnabled())
		WaitMenuMode(5)
		SendModEvent("DBM_Message","stopSharing")
		WaitMenuMode(5)
		DebugTrace("getSharingEnabled() returns " + DBM_Utils.getSharingEnabled())
		DebugTrace("test complete!")
	EndIf
EndEvent

Function DoUpkeep()
	DebugTrace("Doing upkeep...")
	Int iScriptVersion = 1 ;Inc this whenever update code needs to be run
	If !ScriptVersion
		DoInit()
	ElseIf iScriptVersion != ScriptVersion
		DoUpdate(ScriptVersion)
	EndIf
	ScriptVersion = iScriptVersion
	RegisterForModEvent("DBM_Message", "OnDBM_Message")

	If DBMV_SharingEnabled.GetValue() == 1
		DisableInactiveDisplays()
		EnableActiveDisplays()
	EndIf

	SendModEvent("DBM_Message", "delayedTest")

	DebugTrace("Finished upkeep!")
EndFunction

Function DoInit()
; First run on this session
	DebugTrace("First time run!")
	;Disable old standalone version of Persistent Legacy scripts.
	Quest vDBM__MetaQuest = Quest.GetQuest("vDBM__MetaQuest")
	If vDBM__MetaQuest
		If vDBM__MetaQuest.IsRunning()
			DebugTrace("Found old version of vDBM__MetaQuest running, shutting it down...")
			vDBM__MetaQuest.Stop()
		EndIf
	EndIf
	Quest vDBM_DataManagerQuest = Quest.GetQuest("vDBM_DataManagerQuest")
	If vDBM_DataManagerQuest
		If vDBM_DataManagerQuest.IsRunning()
			DebugTrace("Found old version of vDBM_DataManagerQuest running, shutting it down...")
			vDBM_DataManagerQuest.Stop()
		EndIf
	EndIf

	DisableOtherDisplays()

EndFunction

Function DoUpdate(Int iScriptVersion)
;Nothing here yet
	DebugTrace("Upgrading to version " + iScriptVersion + "...")
	DebugTrace("Upgrade complete!")
EndFunction

Function DoFirstLoadScan()
;
; Scan everything on the list and mark the Player as a Contributor. Important to make sure that
; ONLY the Player's own, earned Displays are enabled before doing this, otherwise Displays might 
; get misattributed.
;

	DebugTrace("Scanning all displays...")
	DBM_Utils.saveDisplayStatusList(DBM_DisplayLists)
	DebugTrace("...done!")

EndFunction

Function EnableActiveDisplays()
;
; This just activates all displays activated by other characters.
; It does not DE-activate displays removed by other characters. 
; Use DisableInactiveDisplays for that.
;

	string sPlayerName = PlayerREF.GetActorBase().GetName()

	String[] sContributorList = DBM_Utils.getContributors()

	Int n = 0
	While n < sContributorList.length
		If sPlayerName != sContributorList[n] ; Do not enable our own displays, they should already be enabled!
			ObjectReference[] kDisplayList = DBM_Utils.getActiveDisplays()
			Int i = kDisplayList.Length
			While i > 0
				i -= 1
				ObjectReference kDisplayObj = kDisplayList[i]
				If kDisplayObj
					If kDisplayObj.IsDisabled()
						;DebugTrace("Enabling " + kDisplayObj + "!")
						kDisplayObj.EnableNoWait(True)
					EndIf
				EndIf
			EndWhile
		EndIf
		n += 1
	EndWhile

EndFunction

Function DisableOtherDisplays()
;
; This deactivates all displays that came from other characters.
; Effectively resets the Museum to the normal state, with only the Player's stuff in it.
;

	string sPlayerName = PlayerREF.GetActorBase().GetName()

	String[] sContributorList = DBM_Utils.getContributors()

	Int n = 0
	While n < sContributorList.length
		If sPlayerName != sContributorList[n] ; Do not disable our own displays
			ObjectReference[] kDisplayList = DBM_Utils.getActiveDisplays()
			Int i = kDisplayList.Length
			While i > 0
				i -= 1
				ObjectReference kDisplayObj = kDisplayList[i]
				If kDisplayObj
					If !kDisplayObj.IsDisabled()
						;DebugTrace("Disabling " + kDisplayObj + "!")
						kDisplayObj.DisableNoWait(True)
					EndIf
				EndIf
			EndWhile
		EndIf
		n += 1
	EndWhile

EndFunction


Function DisableInactiveDisplays()
;
; Disable all currently enabled displays that were turned off by other characters
;

	;DebugTrace("Scanning all displays for ones to disable...")
	ObjectReference[] kDisableList = DBM_Utils.getUnwantedDisplays(DBM_DisplayLists)
	;DebugTrace("Excluding displays activated by the Player...")
	ObjectReference[] kPlayerDisplayList = DBM_Utils.getActiveDisplays(PlayerREF.GetActorBase().GetName())
	Int i = kPlayerDisplayList.Length
	While i > 0
		i -= 1
		ObjectReference kObject = kPlayerDisplayList[i]
		Int idx = kDisableList.Find(kObject)
		If idx >= 0
			kDisableList[idx] = None
		EndIf
	EndWhile
	DisableArray(kDisableList)

EndFunction

Function DisableArray(Objectreference[] akObjectList)
	Int n = akObjectList.Length
	While n > 0
		n -= 1
		;DebugTrace("Disabling " + akObjectList[n] + "!")
		If akObjectList[n]
			akObjectList[n].DisableNoWait(True)
		EndIf
	EndWhile
EndFunction

Function TestData()
;
; Just prints some test data to the debug log.
;
	string sPlayerName = Game.GetPlayer().GetActorBase().GetName()

	String[] sContributorList = DBM_Utils.getContributors()

	int n = 0
	while n < sContributorList.length
		ObjectReference[] displayList = DBM_Utils.getActiveDisplays(sContributorList[n])
		int i = 0
		while i < displayList.length
			DebugTrace("DisplayTest: " + sContributorList[n] + " has display " + displayList[i])
			i += 1
		endWhile
		n += 1
	EndWhile

	ObjectReference[] displayList = DBM_Utils.getActiveDisplays() ; get ALL active displays
	n = 0
	while n < displayList.length
		sContributorList = DBM_Utils.getContributorsForDisplay(displayList[n])
		if sContributorList.length
			string sContribCommas = sContributorList[0]
			int i = 1
			while i < sContributorList.length
				sContribCommas += ", " + sContributorList[i]
				i += 1
			endWhile
			DebugTrace("DisplayTest: Contributors for " + displayList[n] + " are " + sContribCommas + "!")
		endIf
		n += 1
	endWhile

EndFunction

Function testListNames(FormList akFormList) Global
;
; Just prints some test data to the debug log.
;
	String[] sNameList = DBM_Utils.GetNameBatch(akFormList)
	Int i = 0
	While i < sNameList.Length
		Debug.Trace("DBM_vMuseumData/testListNames: " + i + " is " + sNameList[i] + "!")
		i += 1
	EndWhile
EndFunction


Function DebugTrace(String sDebugString, Int iSeverity = 0)
	Debug.Trace("vDBM/DataManager: " + sDebugString,iSeverity)
EndFunction
