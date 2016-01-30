#include "common/IFileStream.h"

std::string GetUserDirectory();
bool isReadable(const std::string& name);
UInt32 SSCopyFile(LPCSTR lpExistingFileName, LPCSTR lpNewFileName);
UInt32 SSMoveFile(LPCSTR lpExistingFileName, LPCSTR lpNewFileName);
UInt32 SSDeleteFile(LPCSTR lpExistingFileName);
SInt32 ssRotateFile(const std::string& filename, SInt32 maxCount);