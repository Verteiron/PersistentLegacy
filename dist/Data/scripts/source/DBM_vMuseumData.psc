Scriptname DBM_vMuseumData Hidden
{Module to track which displays have been activated and by which character.}
;
; @author Verteiron, written for icecreamassassin
;
; === [ DBM_vMuseumData.psc ] ============================================---
; @class DBM_vMuseumData
;
; Module for easily flagging various displays as active or inactive for the 
; current character, and tracking these settings across multiple saves via
; DBM_vRegistry.psc. 
; 
; Requires JContainers.
; ========================================================---

Import DBM_vRegistry

String Function PlayerName() Global
	String sPlayerName = JDB.SolveStr(".DBMv.PlayerName")
	If sPlayerName && sPlayerName != "Prisoner"
		Return sPlayerName
	EndIf
	sPlayerName = Game.GetPlayer().GetActorBase().GetName()
	JDB.SolveStrSetter(".DBMv.PlayerName",sPlayerName)
	JDB.writeToFile(JContainers.userDirectory() + "DBMv_JDB.json")
	Return sPlayerName
EndFunction

Int Function GetMuseumData() Global
	;String sPlayerName = PlayerName()
	;Int jMuseumData = GetRegObj(sPlayerName + ".MuseumData")
	Int jMuseumData = GetRegObj("MuseumData")
	If jMuseumData
		Return jMuseumData
	EndIf
	jMuseumData = JMap.Object()
	;SetRegObj(sPlayerName + ".MuseumData",jMuseumData)
	SetRegObj("MuseumData",jMuseumData)

	Return jMuseumData
EndFunction

Int Function GetDisplayFormMap() Global
	Int jMuseumData = GetMuseumData()
	Int jDisplayFormMap = JValue.SolveObj(jMuseumData,".DisplayFormMap")
	If jDisplayFormMap
		Return jDisplayFormMap
	EndIf

	jDisplayFormMap = JFormMap.Object()
	JValue.SolveObjSetter(jMuseumData,".DisplayFormMap",jDisplayFormMap,True)
	SaveReg()

	Return jDisplayFormMap
EndFunction

Int Function GetDisplayDataByObject(ObjectReference akDisplayObj, Bool abCreateIfMissing = True) Global
	If !akDisplayObj
		Debug.Trace("DBM_vMuseumData/GetDisplayDataByObject: Missing ObjectReference!",2)
		Return 0
	EndIf
	Int jDisplayFormMap = GetDisplayFormMap()
	Int jDisplayData = JFormMap.GetObj(jDisplayFormMap,akDisplayObj)
	If jDisplayData
		Return jDisplayData
	EndIf
	
	If abCreateIfMissing
		jDisplayData = JMap.Object()
		; String sDisplayName = akDisplayObj.GetName()
		; If !sDisplayName
		; 	sDisplayName = akDisplayObj.GetBaseObject().GetName()
		; EndIf
		; If !sDisplayName && akDisplayObj.GetLinkedRef()
		;  	sDisplayName = akDisplayObj.GetLinkedRef().GetBaseObject().GetName()
		; EndIf
		; ;Set up a link to the same data via the display name, so we have a backup way to look it up.
		; If sDisplayName
		; 	SetRegObj("MuseumData.Displays." + sDisplayName,jDisplayData)
		; EndIf
		;Set up the data in the DisplayFormMap
		JFormMap.SetObj(jDisplayFormMap,akDisplayObj,jDisplayData)
		SaveReg()
	EndIf
	Return jDisplayData
EndFunction

Function ScanAllDisplays() Global
	DBM_MCMScript MCMScript = Quest.GetQuest("DBM_MCMMenu") as DBM_MCMScript

	; ScanDisplayFormList(MCMScript.DisplayActivators)
	; ScanDisplayFormList(MCMScript.DBM_DaedricDisplays)
	; ScanDisplayFormList(MCMScript.DBM_HOLEDisplays)
	; ScanDisplayFormList(MCMScript.OddityDisplays)
	; ScanDisplayFormList(MCMScript.DBM_HOSDisplays)
	; ScanDisplayFormList(MCMScript.DBM_BCSDisplays)
	; ScanDisplayFormList(MCMScript.DBM_UTDisplays)
	; ScanDisplayFormList(MCMScript.DBM_JARDisplays)
	; ScanDisplayFormList(MCMScript.DBM_ShellDisplays)
	; ScanDisplayFormList(MCMScript.DBM_MILDisplays)
	; ScanDisplayFormList(MCMScript.DBM_HeadsDisplays)
	; ScanDisplayFormList(MCMScript.GemstoneDisplays)
	; ScanDisplayFormList(MCMScript.DBM_FishDisplays)
	; ScanDisplayFormList(MCMScript.DBM_MadMaskerDisplays)
	; ScanDisplayFormList(MCMScript.DBM_AetherealDisplays)

	DBM_Utils.saveAllDisplayStatus(MCMScript.DisplayActivators)
	DBM_Utils.saveAllDisplayStatus(MCMScript.DBM_DaedricDisplays)
	DBM_Utils.saveAllDisplayStatus(MCMScript.DBM_HOLEDisplays)
	DBM_Utils.saveAllDisplayStatus(MCMScript.OddityDisplays)
	DBM_Utils.saveAllDisplayStatus(MCMScript.DBM_HOSDisplays)
	DBM_Utils.saveAllDisplayStatus(MCMScript.DBM_BCSDisplays)
	DBM_Utils.saveAllDisplayStatus(MCMScript.DBM_UTDisplays)
	DBM_Utils.saveAllDisplayStatus(MCMScript.DBM_JARDisplays)
	DBM_Utils.saveAllDisplayStatus(MCMScript.DBM_ShellDisplays)
	DBM_Utils.saveAllDisplayStatus(MCMScript.DBM_MILDisplays)
	DBM_Utils.saveAllDisplayStatus(MCMScript.DBM_HeadsDisplays)
	DBM_Utils.saveAllDisplayStatus(MCMScript.GemstoneDisplays)
	DBM_Utils.saveAllDisplayStatus(MCMScript.DBM_FishDisplays)
	DBM_Utils.saveAllDisplayStatus(MCMScript.DBM_MadMaskerDisplays)
	DBM_Utils.saveAllDisplayStatus(MCMScript.DBM_AetherealDisplays)

	testListNames(MCMScript.DisplayItems)
	testListNames(MCMScript.DBM_DaedricItems)
	testListNames(MCMScript.DBM_HOLEItems)
	testListNames(MCMScript.OddityItems)
	testListNames(MCMScript.DBM_HOSItems)
	testListNames(MCMScript.DBM_BCSItems)
	testListNames(MCMScript.DBM_UTItems)
	testListNames(MCMScript.DBM_JARItems)
	testListNames(MCMScript.DBM_ShellList)
	testListNames(MCMScript.DBM_MILItems)
	testListNames(MCMScript.DBM_HeadsItems)
	testListNames(MCMScript.GemstoneList)
	testListNames(MCMScript.DBM_FishItems)
	testListNames(MCMScript.DBM_MadMaskerItems)
	testListNames(MCMScript.DBM_AetherealItems)

EndFunction

Function testListNames(FormList akFormList) Global
	String[] sNameList = DBM_Utils.GetNameBatch(akFormList)
	Int i = 0
	While i < sNameList.Length
		Debug.Trace("DBM_vMuseumData/testListNames: " + i + " is " + sNameList[i] + "!")
		i += 1
	EndWhile
EndFunction

Function ScanDisplayFormList(FormList akFormList) Global
	Int iCount = 0
	ObjectReference[] kDisplayList = New ObjectReference[128]
	Bool[] bDisplayEnabled = New Bool[128]
	Int i = akFormList.GetSize()

	Int jFormList = JArray.Object()
	JArray.AddFromFormList(jFormList,akFormList)
	JValue.Retain(jFormList,"DBMv_ScanFormList")

	Debug.Trace("DBM_vMuseumData/ScanDisplayFormList: Scanning " + i + " entries in " + akFormList + "...",0)
	While i > 0
		i -= 1
		If i % 20 == 0
			Debug.Trace("DBM_vMuseumData/ScanDisplayFormList: " + i + " entries remaining in " + akFormList + "...",0)
		EndIf
		Form kDisplayForm = JArray.GetForm(jFormList,i) ;akFormList.GetAt(i)
		If kDisplayForm as ObjectReference
			ObjectReference kDisplayObj = kDisplayForm as ObjectReference
			If kDisplayObj.GetLinkedRef()
			 	;Debug.Trace("DBM_vMuseumData/ScanDisplayFormList: Adding LinkedRef " + kDisplayObj.GetLinkedRef() + " from entry " + i + " in " + akFormList + "!",1)
			 	;SetDisplayEnabled(kDisplayObj.GetLinkedRef(),kDisplayObj.GetLinkedRef().IsEnabled())

			 	kDisplayList[iCount] = kDisplayObj.GetLinkedRef()
			 	bDisplayEnabled[iCount] = kDisplayObj.GetLinkedRef().IsEnabled()
			 	iCount += 1
			Else
				;Debug.Trace("DBM_vMuseumData/ScanDisplayFormList: Adding ObjectReference " + kDisplayObj + " from entry " + i + " in " + akFormList + "!",1)
				;SetDisplayEnabled(kDisplayObj,kDisplayObj.IsEnabled())

				kDisplayList[iCount] = kDisplayObj
			 	bDisplayEnabled[iCount] = kDisplayObj.IsEnabled()
				iCount += 1
			EndIf
		ElseIf kDisplayForm as FormList
			Debug.Trace("DBM_vMuseumData/ScanDisplayFormList: Found FormList at entry " + i + " in " + akFormList + ", recursing...",0)
			ScanDisplayFormList(kDisplayForm as FormList)
		Else
			Debug.Trace("DBM_vMuseumData/ScanDisplayFormList: Found NONE at entry " + i + " in " + akFormList + "!",1)
		EndIf
		If iCount == 128
			Debug.Trace("DBM_vMuseumData/ScanDisplayFormList: Array reached limit, dumping!",0)
			SetDisplaysEnabled(kDisplayList,bDisplayEnabled)
			iCount = 0
			kDisplayList = New ObjectReference[128]
			bDisplayEnabled = New Bool[128]
		EndIf
	EndWhile
	If iCount
		SetDisplaysEnabled(kDisplayList,bDisplayEnabled)
	EndIf
	jFormList = JValue.Release(jFormList)
	Debug.Trace("DBM_vMuseumData/ScanDisplayFormList: Finished scanning " + akFormList + "!",0)
EndFunction

Function SetDisplaysEnabled(ObjectReference[] akDisplayList, Bool[] abIsActiveList) Global
	Int i = akDisplayList.Length
	Int jDisplayFormMap = GetDisplayFormMap()
	While i > 0
		i -= 1
		ObjectReference kDisplayObj = akDisplayList[i]
		If kDisplayObj && abIsActiveList[i]
			Int jDisplayData = JMap.Object()
			JValue.SolveIntSetter(jDisplayData,".enabled",abIsActiveList[i] as Int,True)
			JFormMap.SetObj(jDisplayFormMap,kDisplayObj,jDisplayData)
			String sDisplayName = kDisplayObj.GetName()
			If !sDisplayName
				sDisplayName = kDisplayObj.GetBaseObject().GetName()
			EndIf
			If !sDisplayName && kDisplayObj.GetLinkedRef()
			 	sDisplayName = kDisplayObj.GetLinkedRef().GetBaseObject().GetName()
			EndIf
			;Set up a link to the same data via the display name, so we have a backup way to look it up.
			If sDisplayName
				SetRegObj("MuseumData.Displays." + sDisplayName,jDisplayData)
			EndIf
		EndIf
	EndWhile
	SaveReg()
EndFunction

Function SetDisplayEnabled(ObjectReference akDisplayObj, Bool abIsActive = True) Global
	Int jDisplayData = GetDisplayDataByObject(akDisplayObj, abIsActive) ; Create a new entry only if display is active
	If !jDisplayData && !abIsActive
		Return
	EndIf
	If !jDisplayData && abIsActive
		Debug.Trace("DBM_vMuseumData/SetDisplayEnabled: Couldn't find or create DisplayData for " + akDisplayObj + "!",2)
		Return
	EndIf
	JValue.SolveIntSetter(jDisplayData,".enabled",abIsActive as Int,True)
	SaveReg()
EndFunction

