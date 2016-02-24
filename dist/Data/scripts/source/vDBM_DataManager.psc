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

Actor Property PlayerRef Auto

;=== Functions ===--

Function DoFirstLoadScan()
;
; This is a hack on a number of reasons. The best way to do this would probably be to 
; have a function in Legacy somewhere that always returns a list of all the formlists
; that need to be checked, so they can be iterated. Or just merge this functionality
; into Legacy directly.
;

	DebugTrace("Scanning all displays...")
	DBM_MCMScript MCMScript = Quest.GetQuest("DBM_MCMMenu") as DBM_MCMScript

;DBM_DisplayLists (0x070e669a)
	FormList DBM_DisplayLists = GetFormFromFile(0x000e669a, "LegacyoftheDragonborn.esp") as FormList
	DBM_Utils.saveDisplayStatusList(DBM_DisplayLists)

	; DBM_Utils.saveDisplayStatusList(MCMScript.DisplayActivators)
	; DBM_Utils.saveDisplayStatusList(MCMScript.DBM_DaedricDisplays)
	; DBM_Utils.saveDisplayStatusList(MCMScript.DBM_HOLEDisplays)
	; DBM_Utils.saveDisplayStatusList(MCMScript.OddityDisplays)
	; DBM_Utils.saveDisplayStatusList(MCMScript.DBM_HOSDisplays)
	; DBM_Utils.saveDisplayStatusList(MCMScript.DBM_BCSDisplays)
	; DBM_Utils.saveDisplayStatusList(MCMScript.DBM_UTDisplays)
	; DBM_Utils.saveDisplayStatusList(MCMScript.DBM_JARDisplays)
	; DBM_Utils.saveDisplayStatusList(MCMScript.DBM_ShellDisplays)
	; DBM_Utils.saveDisplayStatusList(MCMScript.DBM_MILDisplays)
	; DBM_Utils.saveDisplayStatusList(MCMScript.DBM_HeadsDisplays)
	; DBM_Utils.saveDisplayStatusList(MCMScript.GemstoneDisplays)
	; DBM_Utils.saveDisplayStatusList(MCMScript.DBM_FishDisplays)
	; DBM_Utils.saveDisplayStatusList(MCMScript.DBM_MadMaskerDisplays)
	; DBM_Utils.saveDisplayStatusList(MCMScript.DBM_AetherealDisplays)

	TestData()

	DebugTrace("...done!")
EndFunction

Function SetDisplaysActive()
;
; This just activates all displays activated by other characters.
; It does not DE-activate displays removed by other characters. That will takes
; some additional work, either deactivating everything and reactivating it, or 
; something extra in the SKSE plugin itself.
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
						DebugTrace("Enabling " + kDisplayObj + "!")
						kDisplayObj.EnableNoWait(True)
					EndIf
				EndIf
			EndWhile
		EndIf
		n += 1
	EndWhile

EndFunction

Function DisableInactiveDisplays()
;
; Get a list of all currently enabled displays that should be disabled, then 
; disable them.
;

	DebugTrace("Scanning all displays for ones to disable...")
	DBM_MCMScript MCMScript = Quest.GetQuest("DBM_MCMMenu") as DBM_MCMScript

;DBM_DisplayLists (0x070e669a)
	FormList DBM_DisplayLists = GetFormFromFile(0x000e669a, "LegacyoftheDragonborn.esp") as FormList
	DisableArray(DBM_Utils.getUnwantedDisplays(DBM_DisplayLists))

	; DisableArray(DBM_Utils.getUnwantedDisplays(MCMScript.DisplayActivators))
	; DisableArray(DBM_Utils.getUnwantedDisplays(MCMScript.DBM_DaedricDisplays))
	; DisableArray(DBM_Utils.getUnwantedDisplays(MCMScript.DBM_HOLEDisplays))
	; DisableArray(DBM_Utils.getUnwantedDisplays(MCMScript.OddityDisplays))
	; DisableArray(DBM_Utils.getUnwantedDisplays(MCMScript.DBM_HOSDisplays))
	; DisableArray(DBM_Utils.getUnwantedDisplays(MCMScript.DBM_BCSDisplays))
	; DisableArray(DBM_Utils.getUnwantedDisplays(MCMScript.DBM_UTDisplays))
	; DisableArray(DBM_Utils.getUnwantedDisplays(MCMScript.DBM_JARDisplays))
	; DisableArray(DBM_Utils.getUnwantedDisplays(MCMScript.DBM_ShellDisplays))
	; DisableArray(DBM_Utils.getUnwantedDisplays(MCMScript.DBM_MILDisplays))
	; DisableArray(DBM_Utils.getUnwantedDisplays(MCMScript.DBM_HeadsDisplays))
	; DisableArray(DBM_Utils.getUnwantedDisplays(MCMScript.GemstoneDisplays))
	; DisableArray(DBM_Utils.getUnwantedDisplays(MCMScript.DBM_FishDisplays))
	; DisableArray(DBM_Utils.getUnwantedDisplays(MCMScript.DBM_MadMaskerDisplays))
	; DisableArray(DBM_Utils.getUnwantedDisplays(MCMScript.DBM_AetherealDisplays))

EndFunction

Function DisableArray(Objectreference[] akObjectList)
	Int n = akObjectList.Length
	While n > 0
		n -= 1
		DebugTrace("Disabling " + akObjectList[n] + "!")
		akObjectList[n].DisableNoWait(True)
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
