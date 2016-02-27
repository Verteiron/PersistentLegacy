#include <direct.h>
#include <functional>
#include <random>
#include <algorithm>
#include <set>

#include "skse/GameData.h"
#include "skse/GameExtraData.h"
#include "skse/GameRTTI.h"

#include "json/json.h"

#include "fileutils.h"

#include "PapyrusDBM_Utils.h"

typedef std::vector<TESForm*> FormVec;

class ExtraLinkedRef : public BSExtraData
{
public:
	ExtraLinkedRef();
	virtual ~ExtraLinkedRef();

	UInt32		unk04;
	UInt32		unk08;
	UInt32		handle;

	TESObjectREFR * GetReference();
};

TESObjectREFR * ExtraLinkedRef::GetReference()
{
	TESObjectREFR * reference = NULL;
	if (handle == (*g_invalidRefHandle) || handle == 0)
		return NULL;

	LookupREFRByHandle(&handle, &reference);
	return reference;
}

class ExtraLinkedRefChildren : public BSExtraData
{
public:
	ExtraLinkedRefChildren();
	virtual ~ExtraLinkedRefChildren();

	UInt32		unk01;
	UInt32		unk02;
	UInt32		handle;
	UInt32		unk04;
	UInt32		unk05;
	UInt32		handle2;
	UInt32		unk07;
	UInt32		unk08;
	UInt32		handle3;
	UInt32		unk0a;
	UInt32		unk0b;
	UInt32		handle4;
	UInt32		unk0d;
	UInt32		unk0e;
	UInt32		handle5;

	TESObjectREFR * GetReference();
};

TESObjectREFR * ExtraLinkedRefChildren::GetReference()
{
	TESObjectREFR * reference = NULL;
	if (handle == (*g_invalidRefHandle) || handle == 0)
		return NULL;

	LookupREFRByHandle(&handle, &reference); //works
	return reference;
}


void VisitFormList(BGSListForm * formList, std::function<void(TESForm*)> functor)
//Thanks to Brendan/expired for this one
{
	for (int i = 0; i < formList->forms.count; i++)
	{
		TESForm* childForm = NULL;
		if (formList->forms.GetNthItem(i, childForm))
			functor(childForm);
	}

	// Script Added Forms
	if (formList->addedForms) {
		for (int i = 0; i < formList->addedForms->count; i++) {
			UInt32 formid = 0;
			formList->addedForms->GetNthItem(i, formid);
			TESForm* childForm = LookupFormByID(formid);
			if (childForm)
				functor(childForm);
		}
	}
}

void VisitFormListRecursive(BGSListForm * formList, std::function<void(TESForm*)> functor, UInt8 recurseMax = 3)
{
	if (recurseMax <= 0) {
		_WARNING("%s: Too many recursions, aborting!", __FUNCTION__);
		return;
	}
	_MESSAGE("%s: Checking formlist %08x, recursion %d of 3...", __FUNCTION__, formList->formID, 3 - recurseMax);
	for (int i = 0; i < formList->forms.count; i++)
	{
		TESForm* childForm = NULL;
		if (formList->forms.GetNthItem(i, childForm))
		{
			BGSListForm* childList = NULL;
			childList = DYNAMIC_CAST(childForm, TESForm, BGSListForm);
			if (childList) {
				_MESSAGE("%s: Recursing into formlist %08x...", __FUNCTION__, formList->formID);
				VisitFormListRecursive(childList, functor, recurseMax - 1);
			} else
				functor(childForm);
		}
	}

	// Script Added Forms
	if (formList->addedForms) {
		for (int i = 0; i < formList->addedForms->count; i++) {
			UInt32 formid = 0;
			formList->addedForms->GetNthItem(i, formid);
			TESForm* childForm = LookupFormByID(formid);
			if (childForm) {
				BGSListForm* childList = NULL;
				childList = DYNAMIC_CAST(childForm, TESForm, BGSListForm);
				if (childList) {
					VisitFormListRecursive(formList, functor, recurseMax - 1);
				}
				else
					functor(childForm);
			}
		}
	}
}

bool LoadJsonFromFile(const char * filePath, Json::Value &jsonData)
{
	IFileStream		currentFile;
	if (!currentFile.Open(filePath))
	{
		_ERROR("%s: couldn't open file (%s) Error (%d)", __FUNCTION__, filePath, GetLastError());
		return true;
	}

	char buf[512];

	std::string jsonString;
	while (!currentFile.HitEOF()){
		currentFile.ReadString(buf, sizeof(buf) / sizeof(buf[0]));
		jsonString.append(buf);
	}
	currentFile.Close();
	
	Json::Features features;
	features.all();

	Json::Reader reader(features);

	bool parseSuccess = reader.parse(jsonString, jsonData);
	if (!parseSuccess) {
		_ERROR("%s: Error occured parsing json for %s.", __FUNCTION__, filePath);
		return true;
	}
	return false;
}

Json::Value ReadDisplayData()
{
	Json::Value jsonData;
	char filePath[MAX_PATH];
	sprintf_s(filePath, "%s/DBM_MuseumData.json", GetUserDirectory().c_str());
	LoadJsonFromFile(filePath, jsonData);
	return jsonData;
}

bool WriteDisplayData(Json::Value jDisplayList)
{
	Json::StyledWriter writer;
	std::string jsonString = writer.write(jDisplayList);
	
	if (!jsonString.length()) {
		return true;
	}

	char filePath[MAX_PATH];
	sprintf_s(filePath, "%s/DBM_MuseumData.json", GetUserDirectory().c_str());

	IFileStream	currentFile;
	IFileStream::MakeAllDirs(filePath);
	if (!currentFile.Create(filePath))
	{
		_ERROR("%s: couldn't create preset file (%s) Error (%d)", __FUNCTION__, filePath, GetLastError());
		return true;
	}

	currentFile.WriteBuf(jsonString.c_str(), jsonString.length());
	currentFile.Close();

	return false;
}

bool DeleteDisplayData()
{
	char filePath[MAX_PATH];
	sprintf_s(filePath, "%s/DBM_MuseumData.json", GetUserDirectory().c_str());
	DeleteFile(filePath);
	_rmdir(GetUserDirectory().c_str());

	return false;
}

std::string GetJCFormString(TESForm * form)
{
	/*	Return JContainer-style form serialization
	"__formData|Skyrim.esm|0x1396a"
	"__formData|Dragonborn.esm|0x24037"
	"__formData||0xff000960"					*/

	if (!form)
	{
		return NULL;
	}

	const char * modName = nullptr;

	UInt8 modIndex = form->formID >> 24;
	if (modIndex < 255)
	{
		DataHandler* pDataHandler = DataHandler::GetSingleton();
		ModInfo* modInfo = pDataHandler->modList.modInfoList.GetNthItem(modIndex);
		modName = (modInfo) ? modInfo->name : NULL;
	}

	UInt32 modFormID = (modName) ? (form->formID & 0xFFFFFF) : form->formID;

	char returnStr[MAX_PATH];
	sprintf_s(returnStr, "__formData|%s|0x%x", (modName) ? (modName) : "", modFormID);

	return returnStr;
}

TESForm* GetJCStringForm(std::string formString)
{
	TESForm * result = nullptr;

	std::vector<std::string> stringData;

	std::string formData("__formData");

	std::istringstream str(formString);

	std::string token;
	while (std::getline(str, token, '|')) {
		//std::cout << token << std::endl;
		stringData.push_back(token);
	}

	if (stringData[0] != formData)
		return result;

	if (!stringData[2].length())
		return result;

	UInt8 modIndex = 0xff;

	if (stringData[1].length()) {
		DataHandler* pDataHandler = DataHandler::GetSingleton();
		modIndex = pDataHandler->GetModIndex(stringData[1].c_str());
	}

	if (modIndex == 0xff)
		return result;

	std::string formIdString(stringData[2].c_str());

	UInt32 formId;

	try {
		formId = std::stoul(std::string(formIdString.begin(), formIdString.end()), nullptr, 0);
	}
	catch (const std::invalid_argument&) {
		return result;
	}
	catch (const std::out_of_range&) {
		return result;
	}

	formId |= modIndex << 24;
	result = LookupFormByID(formId);
	return result;
}

std::string getName(TESObjectREFR* pObject)
/**
* @brief	Go to a lot of trouble to get a name for this particular Display.
* @param	pObject The Display to find the name for.
* @return	The name of the Display, or an empty string.
*/
{
	TESObjectREFR* pLinkedObject = nullptr;
	
	ExtraLinkedRefChildren* pLinkedChildren = DYNAMIC_CAST(pObject->extraData.GetByType(kExtraData_LinkedRefChildren), BSExtraData, ExtraLinkedRefChildren);
	if (pLinkedChildren)
	{
		pLinkedObject = pLinkedChildren->GetReference();
	}

	const char * name = nullptr;
	if (pLinkedObject)
	{
		_MESSAGE("Name retrieval: Trying pLinkedObject->GetReferenceName()...");
		name = (pLinkedObject) ? CALL_MEMBER_FN(pLinkedObject, GetReferenceName)() : nullptr;
		if (!name || strlen(name) == 0)
		{
			_MESSAGE("Name retrieval: Trying pLinkedObject as TESFullName...");
			TESFullName* pFullName = DYNAMIC_CAST(pLinkedObject, TESObjectREFR, TESFullName);
			if (pFullName)
			{
				name = pFullName->name.data;
			}
		}
		if (!name || strlen(name) == 0)
		{
			_MESSAGE("Name retrieval: Trying pLinkedObject->baseForm as TESFullName...");
			TESFullName* pFullName = DYNAMIC_CAST(pLinkedObject->baseForm, TESForm, TESFullName);
			if (pFullName)
			{
				name = pFullName->name.data;
			}
		}
	}

	if (!name || strlen(name) == 0)
	{
		_MESSAGE("Name retrieval: Trying pObject->GetReferenceName()...");
		name = (pObject) ? CALL_MEMBER_FN(pObject, GetReferenceName)() : nullptr;
		if (!name || strlen(name) == 0)
		{
			_MESSAGE("Name retrieval: Trying pObject as TESFullName...");
			TESFullName* pFullName = DYNAMIC_CAST(pObject, TESObjectREFR, TESFullName);
			if (pFullName)
			{
				name = pFullName->name.data;
			}
		}
		if (!name || strlen(name) == 0)
		{
			_MESSAGE("Name retrieval: Trying pObject->baseForm as TESFullName...");
			TESFullName* pFullName = DYNAMIC_CAST(pObject->baseForm, TESForm, TESFullName);
			if (pFullName)
			{
				name = pFullName->name.data;
			}
		}
		if (!name || strlen(name) == 0)
		{
			_MESSAGE("Name retrieval: Trying pObject as ExtraTextDisplayData...");
			ExtraTextDisplayData* extraText = DYNAMIC_CAST(pObject->extraData.GetByType(kExtraData_TextDisplayData), BSExtraData, ExtraTextDisplayData);
			if (extraText)
			{
				name = extraText->name.data;
			}
		}
	}

	return name;
}

bool saveDisplayStatus(Json::Value &jsonDisplayList, TESObjectREFR* pObject, const char * playerName = nullptr)
{
	std::string formString = GetJCFormString(pObject);

	Json::Value jsonDisplayData;
	if (jsonDisplayList.isMember(formString.c_str()))
		jsonDisplayData = jsonDisplayList[formString.c_str()];
	
	
	//kFlagUnk_0x800 is the Disabled flag
	if ((pObject->flags & TESForm::kFlagUnk_0x800) && jsonDisplayList.isMember(formString.c_str()))
	{
		//_MESSAGE("Display %s is disabled, but exists on the list.", formString.c_str());
		//Display is disabled, but exists on the list
		Json::Value jsonContributors;
		if (jsonDisplayData.isMember("contributors"))
			jsonContributors = jsonDisplayData["contributors"];

		//Remove this character as a contributor
		for (int index = 0; index < jsonContributors.size(); ++index)
		{
			if (jsonContributors[index].asString() == playerName)
			{
				_MESSAGE("Removing %s from list of contributors.", playerName);
				Json::Value removed;
				jsonContributors.removeIndex(index, &removed);
				index--; //duplicate names shouldn't be a thing, but you never know
				jsonDisplayData["contributors"] = jsonContributors;
			}
		}

		//If this character was the only contributor, remove the entry entirely
		if (!jsonDisplayData.isMember("contributors") || (jsonDisplayData.isMember("contributors") && !jsonContributors.size()))
		{
			_MESSAGE("Last contributor was removed, deleting entry for %s!", formString.c_str());
			jsonDisplayList.removeMember(formString.c_str());
		}
		else {
			jsonDisplayList[formString.c_str()] = jsonDisplayData;
		}
	}
	else if (!(pObject->flags & TESForm::kFlagUnk_0x800)) //If the display is NOT disabled
	{
		_MESSAGE("Display %s is enabled.", formString.c_str());
		
		std::string name = getName(pObject);
		if (name.length() > 0)
		{
			jsonDisplayData["name"] = name.c_str();
		}

		//If playerName is set, add the player's name to the list
		if (playerName)
		{
			Json::Value jsonContributors;
			if (jsonDisplayData.isMember("contributors"))
				jsonContributors = jsonDisplayData["contributors"];
			bool addMe = true;
			for (int index = 0; index < jsonContributors.size(); ++index)
			{
				if (jsonContributors[index].asString() == playerName)
				{
					_MESSAGE("  %s is already in the contributor list.", playerName);
					addMe = false;
				}
			}
			if (addMe)
			{
				_MESSAGE("  Adding %s to the contributor list.", playerName);
				jsonContributors.append(playerName);
				jsonDisplayData["contributors"] = jsonContributors;
			}
		}

		jsonDisplayList[formString.c_str()] = jsonDisplayData;
	}
	return true;
}

namespace papyrusDBM_Utils
{
	void TraceConsole(StaticFunctionTag*, BSFixedString theString)
	{
		Console_Print(theString.data);
	}
	
	BSFixedString userDirectory(StaticFunctionTag*) {
		return GetUserDirectory().c_str();
	}

	void deleteDisplayData(StaticFunctionTag*) {
		DeleteDisplayData();
	}

	void deleteContributor(StaticFunctionTag*, BSFixedString characterName)
	{
		Json::Value jsonDisplayList = ReadDisplayData();
		
		for (auto & jsonDisplay : jsonDisplayList.getMemberNames())
		{
			Json::Value jsonDisplayData = jsonDisplayList[jsonDisplay.c_str()];
			Json::Value jsonContributors;
			if (jsonDisplayData.isMember("contributors"))
				jsonContributors = jsonDisplayData["contributors"];
			
			//Remove this character as a contributor
			for (int index = 0; index < jsonContributors.size(); ++index)
			{
				if (jsonContributors[index].asString() == characterName.data)
				{
					_MESSAGE("Removing %s from list of contributors.", characterName.data);
					Json::Value removed;
					jsonContributors.removeIndex(index, &removed);
					index--; //duplicate names shouldn't be a thing, but you never know
					jsonDisplayData["contributors"] = jsonContributors;
				}
			}

			//If this character was the only contributor, remove the entry entirely
			if (!jsonDisplayData.isMember("contributors") || (jsonDisplayData.isMember("contributors") && !jsonContributors.size()))
			{
				_MESSAGE("Last contributor was removed, deleting entry for %s!", jsonDisplay.c_str());
				jsonDisplayList.removeMember(jsonDisplay.c_str());
			}
			else {
				jsonDisplayList[jsonDisplay.c_str()] = jsonDisplayData;
			}
		}
		WriteDisplayData(jsonDisplayList);
	}

	VMResultArray<BSFixedString> getContributors(StaticFunctionTag*)
	{
		VMResultArray<BSFixedString> results;
		std::set<std::string> resultSet;
		
		Json::Value jsonDisplayList = ReadDisplayData();

		for (auto & jsonDisplay : jsonDisplayList.getMemberNames())
		{
			for (auto & contributor : jsonDisplayList[jsonDisplay.c_str()]["contributors"])
			{
				resultSet.insert(contributor.asString()); // Set will automagically prevent duplicates. Supposedly faster.
			}
		}
		
		for (auto & contributor : resultSet)
		{
			results.push_back(contributor.c_str());
		}
		return results;
	}

	VMResultArray<BSFixedString> getContributorsForDisplay(StaticFunctionTag*, TESObjectREFR* pObject)
	{
		VMResultArray<BSFixedString> results;
		std::set<std::string> resultSet;

		if (!pObject)
			return results;

		Json::Value jsonDisplayList = ReadDisplayData();
		std::string formString = GetJCFormString(pObject);

		for (auto & contributor : jsonDisplayList[formString.c_str()]["contributors"])
		{
			if (!contributor.asString().empty())
				results.push_back(contributor.asString().c_str());
		}
		
		return results;
	}

	VMResultArray<TESObjectREFR*> getActiveDisplays(StaticFunctionTag*, BSFixedString characterName)
	{
		VMResultArray<TESObjectREFR*> results;
		Json::Value jsonDisplayList = ReadDisplayData();

		for (auto & jsonDisplay : jsonDisplayList.getMemberNames()) 
		{
			TESObjectREFR* displayObj = DYNAMIC_CAST(GetJCStringForm(jsonDisplay), TESForm, TESObjectREFR);
			
			if (strlen(characterName.data))
			{
				for (auto & contributor : jsonDisplayList[jsonDisplay.c_str()]["contributors"])
				{
					if (contributor.asString() == characterName.data)
						results.push_back(displayObj);
				}
			} 
			else 
			{
				results.push_back(displayObj);
			}
		}
		
		return results;
	}

	void saveDisplayStatus(StaticFunctionTag*, TESObjectREFR* pObject, bool addContributor = true)
	{
		Json::Value jsonDisplayList = ReadDisplayData();

		const char * playerName = nullptr;

		TESFullName* pPlayerName = DYNAMIC_CAST((*g_thePlayer)->baseForm, TESForm, TESFullName);
		if (pPlayerName)
			playerName = pPlayerName->name.data;
		
		if (!saveDisplayStatus(jsonDisplayList, pObject, addContributor ? playerName : nullptr))
			_WARNING("Problem saving Display with FormID %08x", pObject->formID);

		WriteDisplayData(jsonDisplayList);
	}

	void saveDisplayStatusList(StaticFunctionTag*, BGSListForm* displayList, bool addContributor = true)
	{
		Json::Value jsonDisplayList = ReadDisplayData();

		const char * playerName = nullptr;

		TESFullName* pPlayerName = DYNAMIC_CAST((*g_thePlayer)->baseForm, TESForm, TESFullName);
		if (pPlayerName)
			playerName = pPlayerName->name.data;
		
		VisitFormListRecursive(displayList, [&](TESForm * form){
			TESObjectREFR * pObject = DYNAMIC_CAST(form, TESForm, TESObjectREFR);
			if (pObject) {
				if (!saveDisplayStatus(jsonDisplayList, pObject, addContributor ? playerName : nullptr))
					_WARNING("Problem saving Display with FormID %08x", pObject->formID);
			}
		});
		
		WriteDisplayData(jsonDisplayList);
		
	}

	VMResultArray<TESObjectREFR*> getUnwantedDisplays(StaticFunctionTag*, BGSListForm* displayList)
	{
		VMResultArray<TESObjectREFR*> results;
		Json::Value jsonDisplayList = ReadDisplayData();

		VisitFormListRecursive(displayList, [&](TESForm * form) {
			TESObjectREFR * pObject = DYNAMIC_CAST(form, TESForm, TESObjectREFR);
			if (pObject) {
				std::string formString = GetJCFormString(pObject);
				if (!(pObject->flags & TESForm::kFlagUnk_0x800) && !jsonDisplayList.isMember(formString.c_str()))
					results.push_back(pObject); //Object is Enabled, but not on the saved list
			}
		});

		return results;
	}

	VMResultArray<BSFixedString> getNameBatch(StaticFunctionTag*, BGSListForm* displayList)
	{
		VMResultArray<BSFixedString> result;

		VisitFormList(displayList, [&](TESForm * form){
			if (form) {
				TESFullName* pFullName = DYNAMIC_CAST(form, TESForm, TESFullName);
				if (pFullName) {
					result.push_back(pFullName->name.data);
				}
				else {
					result.push_back("");
				}
			}
		});
		return result;
	}

}

#include "skse/PapyrusVM.h"
#include "skse/PapyrusNativeFunctions.h"

void papyrusDBM_Utils::RegisterFuncs(VMClassRegistry* registry)
{
	registry->RegisterFunction(
		new NativeFunction1<StaticFunctionTag, void, BSFixedString>("TraceConsole", "DBM_Utils", papyrusDBM_Utils::TraceConsole, registry));

	registry->RegisterFunction(
		new NativeFunction0<StaticFunctionTag, BSFixedString>("userDirectory", "DBM_Utils", papyrusDBM_Utils::userDirectory, registry));

	registry->RegisterFunction(
		new NativeFunction0<StaticFunctionTag, void>("deleteDisplayData", "DBM_Utils", papyrusDBM_Utils::deleteDisplayData, registry));

	registry->RegisterFunction(
		new NativeFunction1<StaticFunctionTag, void, BSFixedString>("deleteContributor", "DBM_Utils", papyrusDBM_Utils::deleteContributor, registry));

	registry->RegisterFunction(
		new NativeFunction0<StaticFunctionTag, VMResultArray<BSFixedString>>("getContributors", "DBM_Utils", papyrusDBM_Utils::getContributors, registry));

	registry->RegisterFunction(
		new NativeFunction1<StaticFunctionTag, VMResultArray<BSFixedString>, TESObjectREFR*>("getContributorsForDisplay", "DBM_Utils", papyrusDBM_Utils::getContributorsForDisplay, registry));

	registry->RegisterFunction(
		new NativeFunction1<StaticFunctionTag, VMResultArray<TESObjectREFR*>, BSFixedString>("getActiveDisplays", "DBM_Utils", papyrusDBM_Utils::getActiveDisplays, registry));

	registry->RegisterFunction(
		new NativeFunction1<StaticFunctionTag, VMResultArray<TESObjectREFR*>, BGSListForm*>("getUnwantedDisplays", "DBM_Utils", papyrusDBM_Utils::getUnwantedDisplays, registry));

	registry->RegisterFunction(
		new NativeFunction2<StaticFunctionTag, void, TESObjectREFR*, bool>("saveDisplayStatus", "DBM_Utils", papyrusDBM_Utils::saveDisplayStatus, registry));

	registry->RegisterFunction(
		new NativeFunction2<StaticFunctionTag, void, BGSListForm*, bool>("saveDisplayStatusList", "DBM_Utils", papyrusDBM_Utils::saveDisplayStatusList, registry));

	registry->RegisterFunction(
		new NativeFunction1<StaticFunctionTag, VMResultArray<BSFixedString>, BGSListForm*>("getNameBatch", "DBM_Utils", papyrusDBM_Utils::getNameBatch, registry));
}
