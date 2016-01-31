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
	DebugTrace("Scanning all displays...")
	DBM_MCMScript MCMScript = Quest.GetQuest("DBM_MCMMenu") as DBM_MCMScript

	DBM_Utils.saveDisplayStatusList(MCMScript.DisplayActivators)
	DBM_Utils.saveDisplayStatusList(MCMScript.DBM_DaedricDisplays)
	DBM_Utils.saveDisplayStatusList(MCMScript.DBM_HOLEDisplays)
	DBM_Utils.saveDisplayStatusList(MCMScript.OddityDisplays)
	DBM_Utils.saveDisplayStatusList(MCMScript.DBM_HOSDisplays)
	DBM_Utils.saveDisplayStatusList(MCMScript.DBM_BCSDisplays)
	DBM_Utils.saveDisplayStatusList(MCMScript.DBM_UTDisplays)
	DBM_Utils.saveDisplayStatusList(MCMScript.DBM_JARDisplays)
	DBM_Utils.saveDisplayStatusList(MCMScript.DBM_ShellDisplays)
	DBM_Utils.saveDisplayStatusList(MCMScript.DBM_MILDisplays)
	DBM_Utils.saveDisplayStatusList(MCMScript.DBM_HeadsDisplays)
	DBM_Utils.saveDisplayStatusList(MCMScript.GemstoneDisplays)
	DBM_Utils.saveDisplayStatusList(MCMScript.DBM_FishDisplays)
	DBM_Utils.saveDisplayStatusList(MCMScript.DBM_MadMaskerDisplays)
	DBM_Utils.saveDisplayStatusList(MCMScript.DBM_AetherealDisplays)

	; testListNames(MCMScript.DisplayItems)
	; testListNames(MCMScript.DBM_DaedricItems)
	; testListNames(MCMScript.DBM_HOLEItems)
	; testListNames(MCMScript.OddityItems)
	; testListNames(MCMScript.DBM_HOSItems)
	; testListNames(MCMScript.DBM_BCSItems)
	; testListNames(MCMScript.DBM_UTItems)
	; testListNames(MCMScript.DBM_JARItems)
	; testListNames(MCMScript.DBM_ShellList)
	; testListNames(MCMScript.DBM_MILItems)
	; testListNames(MCMScript.DBM_HeadsItems)
	; testListNames(MCMScript.GemstoneList)
	; testListNames(MCMScript.DBM_FishItems)
	; testListNames(MCMScript.DBM_MadMaskerItems)
	; testListNames(MCMScript.DBM_AetherealItems)

	TestData()

	DebugTrace("...done!")
EndFunction

Function SetDisplaysActive()
	ObjectReference[] kDisplayList = DBM_Utils.getActiveDisplays()
	Int i = kDisplayList.Length
	While i > 0
		i -= 1
		ObjectReference kDisplayObj = kDisplayList[i]
		If kDisplayObj
			If kDisplayObj.IsDisabled()
				DebugTrace("Enabling " + kDisplayObj + " (" + kDisplayObj.GetBaseObject().GetName() + ")")
				kDisplayObj.EnableNoWait()
			EndIf
		EndIf
	EndWhile
EndFunction

Function TestData()
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

EndFunction

Function testListNames(FormList akFormList) Global
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
