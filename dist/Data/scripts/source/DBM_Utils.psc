Scriptname DBM_Utils Hidden
{Series of utility functions provided by the SKSE plugin.}

Function TraceConsole(String asTrace) native global
{Print a string to the console.}

String Function userDirectory() native global
{Returns "%UserProfile%/My Documents/My Games/Skyrim/DBM_Utils".}

ObjectReference[] Function getActiveDisplays(String asCharacterName = "") native global
{
/**
*  @brief 	Get an array with all the Displays that are enabled for a character, or all characters.
*  @param	asCharacterName 		Name of the character to get a list for, or empty string for all characters.
*  @return	Array of ObjectReferences that should be enabled for the requested character.
*/
}

Function saveAllDisplayStatus(FormList akDisplayList, Bool abAddContributor = True) native global
{
/**
*  @brief 	Writes out the name and enabed status of all the displays in a formlist.
*  @param	akDisplayList 		FormList of displays to check.
*  @param	abAddContributor	If true, add the current player to the list of contributors for the display.
*/
}

String[] Function getNameBatch(FormList akFormList) native global
{
/**
*  @brief 	Return an array containing the names of every form in akFormList.
*  @param	akFormList 			FormList containing everything you want the name of.
*  @return	Array of Strings containing the form names, or an empty string if the name couldn't be found.
*/
}

String Function GetFormIDString(Form akForm) Global
	String sResult
	sResult = akForm as String ; [FormName < (FF000000)>]
	sResult = StringUtil.SubString(sResult,StringUtil.Find(sResult,"(") + 1,8)
	Return sResult
EndFunction