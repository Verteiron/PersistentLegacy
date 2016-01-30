Scriptname DBM_vRegistry Hidden
{Abstracted interface for JContainers that handles data synchronization between game saves.}
;
; === [ DBM_vRegistry.psc ] ===============================================---
; @class DBM_vRegistry
; Abstracted interface for JContainers that handles data synchronization 
; between game saves. Automatically saves/loads file based on incrementing
; serial number. Can also be used to link JContainer objects to forms.
;
; Customized version of DBMv_Registry written for icecreamassassin.
;
; @author Verteiron
; ========================================================---

Function InitReg() Global
	Int jRegData = CreateRegDataIfMissing()
	SyncReg()
EndFunction

Function SyncReg() Global
	Int jRegData = JDB.solveObj(".DBMv.Registry")
	If !jRegData
		jRegData = JMap.Object()
		JDB.solveObjSetter(".DBMv.Registry",jRegData,True)
	EndIf
	Int jRegFileData = JValue.ReadFromFile(JContainers.userDirectory() + "DBMv_Registry.json")
	Int DataSerial = JMap.getInt(jRegData,"DataSerial")
	Int DataFileSerial = JMap.getInt(jRegFileData,"DataSerial")
	;Debug.Trace("DBMv/Reg: SyncReg called! Our DataSerial is " + DataSerial + ", file DataSerial is " + DataFileSerial)
	If DataSerial > DataFileSerial
		;Debug.Trace("DBMv/Reg: Our data is newer than the saved file, overwriting it!")
		JValue.WriteToFile(jRegData,JContainers.userDirectory() + "DBMv_Registry.json")
	ElseIf DataSerial < DataFileSerial
		;Debug.Trace("DBMv/Reg: Our data is older than the saved file, loading it!")
		JValue.Clear(jRegData)
		jRegData = JValue.ReadFromFile(JContainers.userDirectory() + "DBMv_Registry.json")
		JDB.solveObjSetter(".DBMv.Registry",jRegData)
	Else
		;Already synced. Sunc?
	EndIf
EndFunction

Function LoadReg() Global
	;Debug.Trace("DBMv/Reg: LoadReg called!")
	Int jRegData = JDB.solveObj(".DBMv.Registry")
	jRegData = JValue.ReadFromFile(JContainers.userDirectory() + "DBMv_Registry.json")
EndFunction

Function SaveReg() Global
	;Debug.Trace("DBMv/Reg: SaveReg called!")
	Int jRegData = JDB.solveObj(".DBMv.Registry")
	JMap.setInt(jRegData,"DataSerial",JMap.getInt(jRegData,"DataSerial") + 1)
	JValue.WriteToFile(jRegData,JContainers.userDirectory() + "DBMv_Registry.json")
EndFunction

Int Function CreateRegDataIfMissing() Global
	Int jRegData = JDB.solveObj(".DBMv.Registry")
	If jRegData
		JMap.setInt(jRegData,"DataSerial",JMap.getInt(jRegData,"DataSerial") + 1)
		Return jRegData
	EndIf
	;Debug.Trace("DBMv/Reg: First RegData access, creating JDB key!")
	Int _jDBMv = JDB.solveObj(".DBMv")
	jRegData = JValue.ReadFromFile(JContainers.userDirectory() + "DBMv_Registry.json")
	If jRegData
		;Debug.Trace("DBMv/Reg: Loaded Reg file!")
	Else
		;Debug.Trace("DBMv/Reg: No Reg file found, creating new RegData data!")
		jRegData = JMap.Object()
		JMap.setInt(jRegData,"DataSerial",0)
	EndIf
	JMap.setObj(_jDBMv,"Registry",jRegData)
	Return jRegData
EndFunction

Bool Function HasRegKey(String asPath) Global
	Int jReg = CreateRegDataIfMissing()
	Return JValue.hasPath(jReg,"." + asPath) || JMap.hasKey(jReg,asPath)
EndFunction

Function ClearRegKey(String asPath) Global
	Int jReg = CreateRegDataIfMissing()
	JValue.solveObjSetter(jReg,"." + asPath,0)
EndFunction

Function SetRegStr(String asPath, String asString, Bool abDeferSave = False) Global
	Int jReg = CreateRegDataIfMissing()
	JValue.solveStrSetter(jReg,"." + asPath,asString,True)
	If !abDeferSave
		SyncReg()
	EndIf
EndFunction

String Function GetRegStr(String asPath) Global
	Return JDB.solveStr(".DBMv.Registry." + asPath)
EndFunction

Function SetRegBool(String asPath, Bool abBool, Bool abDeferSave = False) Global
	Int jReg = CreateRegDataIfMissing()
	JValue.solveIntSetter(jReg,"." + asPath,abBool as Int,True)

	If !abDeferSave
		SyncReg()
	EndIf
EndFunction

Bool Function GetRegBool(String asPath) Global
	Return JDB.solveInt(".DBMv.Registry." + asPath) as Bool
EndFunction

Bool Function ToggleRegBool(String asPath, Bool abDeferSave = False) Global
	Int jReg = CreateRegDataIfMissing()
	Bool bToggleValue = !(GetRegBool(asPath))
	JValue.solveIntSetter(jReg,"." + asPath,bToggleValue as Int,True)

	If !abDeferSave
		SyncReg()
	EndIf
	Return bToggleValue
EndFunction

Function SetRegInt(String asPath, Int aiInt, Bool abDeferSave = False) Global
	Int jReg = CreateRegDataIfMissing()
	JValue.solveIntSetter(jReg,"." + asPath,aiInt,True)

	If !abDeferSave
		SyncReg()
	EndIf
EndFunction

Int Function GetRegInt(String asPath) Global
	Return JDB.solveInt(".DBMv.Registry." + asPath)
EndFunction

Function SetRegFlt(String asPath, Float afFloat, Bool abDeferSave = False) Global
	Int jReg = CreateRegDataIfMissing()
	JValue.solveFltSetter(jReg,"." + asPath,afFloat,True)

	If !abDeferSave
		SyncReg()
	EndIf
EndFunction

Float Function GetRegFlt(String asPath) Global
	Return JDB.solveFlt(".DBMv.Registry." + asPath)
EndFunction

Function SetRegForm(String asPath, Form akForm, Bool abDeferSave = False) Global
	Int jReg = CreateRegDataIfMissing()
	JValue.solveFormSetter(jReg,"." + asPath,akForm,True)

	If !abDeferSave
		SyncReg()
	EndIf
EndFunction

Form Function GetRegForm(String asPath) Global
	Return JDB.solveForm(".DBMv.Registry." + asPath)
EndFunction

Function SetRegObj(String asPath, Int ajObj, Bool abDeferSave = False) Global
	Int jReg = CreateRegDataIfMissing()
	JValue.solveObjSetter(jReg,"." + asPath,ajObj,True)

	If !abDeferSave
		SyncReg()
	EndIf
EndFunction

Int Function GetRegObj(String asPath) Global
	Return JDB.solveObj(".DBMv.Registry." + asPath)
EndFunction

String Function GetUUID(Bool abFast = True) Global
	If abFast
		Return GetUUIDFast()
	EndIf
	Return GetUUIDTrue()
EndFunction

String Function GetUUIDTrue() Global
{This should be identical to GetUUIDFast, but follows the proper procedure for generating the randoms.}
	Int[] iBytes = New Int[16]
	Int i = 0
	While i < 16
		iBytes[i] = Utility.RandomInt(0,255)
		i += 1
	EndWhile
	Int iVersion = iBytes[6]
	iVersion = Math.LogicalOr(Math.LogicalAnd(iVersion,0x0f),0x40)
	iBytes[6] = iVersion
	Int iVariant = iBytes[8]
	iVariant = Math.LogicalOr(Math.LogicalAnd(iVariant,0x3f),0x80)
	iBytes[8] = iVariant
	String sUUID = ""
	i = 0
	While i < 16
		If iBytes[i] < 16
			sUUID += "0"
		EndIf
		sUUID += GetHexString(iBytes[i])
		If i == 3 || i == 5 || i == 7 || i == 9
			sUUID += "-"
		EndIf
		i += 1
	EndWhile
	Return sUUID
EndFunction

String Function GetUUIDFast() Global
	String sUUID = ""
	sUUID += GetHexString(Utility.RandomInt(0,0xffff),4) + GetHexString(Utility.RandomInt(0,0xffff),4)
	sUUID += "-"
	sUUID += GetHexString(Utility.RandomInt(0,0xffff),4)
	sUUID += "-"
	sUUID += GetHexString(Math.LogicalOr(Math.LogicalAnd(Utility.RandomInt(0,0xffff),0x0fff),0x4000)) ; version
	sUUID += "-"
	sUUID += GetHexString(Math.LogicalOr(Math.LogicalAnd(Utility.RandomInt(0,0xffff),0x3fff),0x8000)) ; variant
	sUUID += "-"
	sUUID += GetHexString(Utility.RandomInt(0,0xffffff),6) + GetHexString(Utility.RandomInt(0,0xffffff),6)
	Return sUUID
EndFunction

String Function GetHexString(Int iDec, Int iPadLength = 0) Global
	If iDec < 0
		Return ""
	ElseIf iDec == 0
		Return "0"
	EndIf
	String[] sHexT = New String[6]
	sHexT[0] = "a"
	sHexT[1] = "b"
	sHexT[2] = "c"
	sHexT[3] = "d"
	sHexT[4] = "e"
	sHexT[5] = "f"
	String sHex = ""
	If iDec > 15
		sHex += GetHexString(iDec / 16)
		sHex += GetHexString(iDec % 16)
	ElseIf iDec > 9
		sHex = sHexT[iDec - 10]
	ElseIf iDec 
		sHex = iDec
	Else
		sHex = "0"
	EndIf
	If iPadLength
		Int iHexLen = StringUtil.GetLength(sHex)
		If iHexLen < iPadLength
			sHex = StringUtil.Substring("0000000000000000",0,iPadLength - iHexLen) + sHex
		EndIf
	EndIf
	Return sHex
EndFunction

Int Function GetVersionInt(Int iMajor, Int iMinor, Int iPatch) Global
	Return Math.LeftShift(iMajor,16) + Math.LeftShift(iMinor,8) + iPatch
EndFunction

String Function MakePath(String asPath) Global
	If StringUtil.GetNthChar(asPath,0) == "."
		Return asPath
	EndIf
	Return "." + asPath
EndFunction
