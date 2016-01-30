#include <shlobj.h>
#include "fileutils.h"

std::string GetUserDirectory()
{
	char path[MAX_PATH];
	if (!SUCCEEDED(SHGetFolderPath(NULL, CSIDL_MYDOCUMENTS | CSIDL_FLAG_CREATE, NULL, SHGFP_TYPE_CURRENT, path)))
	{
		return std::string();
	}
	strcat_s(path, sizeof(path), "\\My Games\\Skyrim\\DBM_Utils\\");
	return path;
}

bool isReadable(const std::string& name) {
	FILE *file;

	if (fopen_s(&file, name.c_str(), "r") == 0) {
		fclose(file);
		return true;
	}
	else {
		return false;
	}
}


UInt32 SSCopyFile(LPCSTR lpExistingFileName, LPCSTR lpNewFileName)
{
	UInt32 ret = 0;
	if (!isReadable(lpExistingFileName))
	{
		return ERROR_FILE_NOT_FOUND;
	}
	IFileStream::MakeAllDirs(lpNewFileName);
	if (!CopyFile(lpExistingFileName, lpNewFileName, false)) {
		UInt32 lastError = GetLastError();
		ret = lastError;
		switch (lastError) {
		case ERROR_FILE_NOT_FOUND: // We don't need to display a message for this
			break;
		default:
			_ERROR("%s - error copying file %s (Error %d)", __FUNCTION__, lpExistingFileName, lastError);
			break;
		}
	}
	return ret;
}

UInt32 SSMoveFile(LPCSTR lpExistingFileName, LPCSTR lpNewFileName)
{
	UInt32 ret = 0;
	if (!isReadable(lpExistingFileName))
	{
		return ERROR_FILE_NOT_FOUND;
	}
	IFileStream::MakeAllDirs(lpNewFileName);
	if (!MoveFile(lpExistingFileName, lpNewFileName)) {
		UInt32 lastError = GetLastError();
		ret = lastError;
		switch (lastError) {
		case ERROR_FILE_NOT_FOUND: // We don't need to display a message for this
			break;
		default:
			_ERROR("%s - error moving file %s (Error %d)", __FUNCTION__, lpExistingFileName, lastError);
			break;
		}
	}
	return ret;
}

UInt32 SSDeleteFile(LPCSTR lpExistingFileName)
{
	UInt32 ret = 0;
	if (!isReadable(lpExistingFileName))
	{
		return ERROR_FILE_NOT_FOUND;
	}
	if (!DeleteFile(lpExistingFileName)) {
		UInt32 lastError = GetLastError();
		ret = lastError;
		_ERROR("%s - error moving file %s (Error %d)", __FUNCTION__, lpExistingFileName, lastError);
	}
	return ret;
}
