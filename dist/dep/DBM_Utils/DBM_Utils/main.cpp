#include <ShlObj.h>

#include "skse/PluginAPI.h"
#include "skse/skse_version.h"
#include "skse/SafeWrite.h"
#include "skse/GameAPI.h"

#include "PapyrusDBM_Utils.h"

IDebugLog	gLog;

PluginHandle	g_pluginHandle = kPluginHandle_Invalid;

SKSEMessagingInterface *g_messaging = NULL;

SKSEPapyrusInterface              * g_papyrus = NULL;

//const jc::reflection_interface * g_jContainersRootInterface = NULL;

extern "C"
{

#define MIN_PAP_VERSION 1

bool SKSEPlugin_Query(const SKSEInterface * skse, PluginInfo * info)
{
	gLog.OpenRelative(CSIDL_MYDOCUMENTS, "\\My Games\\Skyrim\\SKSE\\skse_DBM_Utils.log");
	_DMESSAGE("skse_DBM_Utils");

	// populate info structure
	info->infoVersion =	PluginInfo::kInfoVersion;
	info->name =		"DBM_Utils";
	info->version =		1;

	// store plugin handle so we can identify ourselves later
	g_pluginHandle = skse->GetPluginHandle();

	if(skse->isEditor)
	{
		_FATALERROR("loaded in editor, marking as incompatible");
		return false;
	}
	else if(skse->runtimeVersion != RUNTIME_VERSION_1_9_32_0)
	{
		_FATALERROR("unsupported runtime version %08X", skse->runtimeVersion);
		return false;
	}

	// get the papyrus interface and query its version
	g_papyrus = (SKSEPapyrusInterface *)skse->QueryInterface(kInterface_Papyrus);
	if (!g_papyrus)
	{
		_FATALERROR("couldn't get papyrus interface");
		return false;
	}
	if (g_papyrus->interfaceVersion < MIN_PAP_VERSION)
	{
		_FATALERROR("papyrus interface too old (%d expected %d)", g_papyrus->interfaceVersion, MIN_PAP_VERSION);
		return false;
	}
	g_messaging = (SKSEMessagingInterface *)skse->QueryInterface(kInterface_Messaging);
	if (!g_messaging) {
		_ERROR("couldn't get messaging interface");
	}

	// supported runtime version
	return true;
}

bool RegisterFuncs(VMClassRegistry * registry)
{
	papyrusDBM_Utils::RegisterFuncs(registry);
	return true;
}

bool SKSEPlugin_Load(const SKSEInterface * skse)
{
	if (g_papyrus)
		g_papyrus->Register(RegisterFuncs);

	return true;
}

};
