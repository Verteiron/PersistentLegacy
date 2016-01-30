@echo off
SET SOURCEDIR=C:\Program Files (x86)\Steam\steamapps\common\skyrim\Data
SET TARGETDIR=%USERPROFILE%\Dropbox\SkyrimMod\PersistentLegacy\dist\Data
SET DEPSOURCEDIR=D:\Projects\SKSE\DBM_Utils
SET DEPTARGETDIR=%USERPROFILE%\Dropbox\SkyrimMod\PersistentLegacy\dist\dep\DBM_Utils

xcopy /E /U /Y "%SOURCEDIR%\*" "%TARGETDIR%\"
xcopy /E /D /U /Y "%DEPSOURCEDIR%\*" "%DEPTARGETDIR%\"
