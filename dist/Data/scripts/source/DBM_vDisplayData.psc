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

Int Function GetMuseumData() Global
	String sPlayerName = Game.GetPlayer().GetActorBase().GetName()
	Int jMuseumData = GetRegObj(sPlayerName + ".MuseumData")
	If !jMuseumData
		jMuseumData = JMap.Object()
		SetRegObj(sPlayerName + ".MuseumData",jMuseumData)
	EndIf
	Return jMuseumData
EndFunction

Int Function GetDisplayData() Global
	Int jMuseumData = GetDisplayData()
	Int jDisplayFormMap = JValue.SolveObj(jMuseumData,".DisplayFormMap")
	If !JValue.IsFormMap(jDisplayFormMap)
		jDisplayFormMap = JFormMap.Object()
		JValue.SolveObjSetter(jMuseumData,".DisplayFormMap",jDisplayFormMap)

	EndIf
	Return jMuseumData
EndFunction

Function SetDisplayEnabled(ObjectReference akDisplay, Bool abIsActive = True) Global
	If !akDisplay
		Debug.Trace("DBM_vMuseumData: Missing ObjectReference!")
		Return
	EndIf
	Int jDisplayFormMap = JValue.SolveObj(GetDisplayData(),".DisplayFormMap")
	Int jDisplay
	JValue.SolveIntSetter(jDisplayFormMap,".enabled",abIsActive as Int)
EndFunction
