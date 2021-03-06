;* Process Hacker - Installer script
;*
;* Copyright (C) 2009 XhmikosR
;*
;* This file is part of Process Hacker.
;*
;* Process Hacker is free software; you can redistribute it and/or modify
;* it under the terms of the GNU General Public License as published by
;* the Free Software Foundation, either version 3 of the License, or
;* (at your option) any later version.
;*
;* Process Hacker is distributed in the hope that it will be useful,
;* but WITHOUT ANY WARRANTY; without even the implied warranty of
;* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;* GNU General Public License for more details.
;*
;* You should have received a copy of the GNU General Public License
;* along with Process Hacker.  If not, see <http://www.gnu.org/licenses/>.


; Inno Setup v5.3.5
;
; Requirements:
; *Inno Setup QuickStart Pack:
;   http://www.jrsoftware.org/isdl.php#qsp


#define installer_build_number "38"

#define VerMajor
#define VerMinor
#define VerRevision
#define VerBuild

#expr ParseVersion("..\..\bin\Release\ProcessHacker.exe", VerMajor, VerMinor, VerRevision, VerBuild)
#define app_version str(VerMajor) + "." + str(VerMinor) + "." + str(VerRevision) + "." + str(VerBuild)
#define simple_app_version str(VerMajor) + "." + str(VerMinor)
#define installer_build_date GetDateTimeString('dd/mm/yyyy', '.', '')


; From now on you'll probably won't have to change anything, so be careful
[Setup]
AppID=Process_Hacker
AppCopyright=Copyright � 2008-2009, Process Hacker Team. Licensed under the GNU GPL, v3.
AppContact=http://sourceforge.net/tracker/?group_id=242527
AppName=Process Hacker
AppVerName=Process Hacker {#= simple_app_version}
AppVersion={#= simple_app_version}
AppPublisher=wj32
AppPublisherURL=http://processhacker.sourceforge.net/
AppSupportURL=http://sourceforge.net/tracker/?group_id=242527
AppUpdatesURL=http://processhacker.sourceforge.net/
UninstallDisplayName=Process Hacker {#= simple_app_version}
DefaultDirName={pf}\Process Hacker
DefaultGroupName=Process Hacker
VersionInfoCompany=wj32
VersionInfoCopyright=Licensed under the GNU GPL, v3.
VersionInfoDescription=Process Hacker {#= simple_app_version} Setup
VersionInfoTextVersion={#= app_version}
VersionInfoVersion={#= app_version}
VersionInfoProductName=Process Hacker
VersionInfoProductVersion={#= app_version}
VersionInfoProductTextVersion={#= app_version}
MinVersion=0,5.01.2600
AppReadmeFile={app}\README.txt
LicenseFile=..\..\..\LICENSE.txt
InfoAfterFile=..\..\..\CHANGELOG.txt
SetupIconFile=Icons\ProcessHacker.ico
UninstallDisplayIcon={app}\ProcessHacker.exe
WizardImageFile=Icons\ProcessHackerLarge.bmp
WizardSmallImageFile=Icons\ProcessHackerSmall.bmp
OutputDir=.
OutputBaseFilename=processhacker-{#= simple_app_version}-setup
AllowNoIcons=True
Compression=lzma/ultra64
SolidCompression=True
InternalCompressLevel=ultra64
EnableDirDoesntExistWarning=False
DirExistsWarning=No
ShowTasksTreeLines=True
AlwaysShowDirOnReadyPage=True
AlwaysShowGroupOnReadyPage=True
WizardImageStretch=False
PrivilegesRequired=Admin
ShowLanguageDialog=Auto
DisableDirPage=Auto
DisableProgramGroupPage=Auto
LanguageDetectionMethod=uilanguage
AppMutex=Global\ProcessHackerMutex
ArchitecturesInstallIn64BitMode=x64


[Languages]
; Installer's languages
Name: en; MessagesFile: compiler:Default.isl
Name: gr; MessagesFile: Languages\Greek.isl


; Include the installer's custom messages and services stuff
#include "Custom_Messages.iss"
#include "Services.iss"


[Messages]
BeveledLabel=Process Hacker v{#= simple_app_version} by wj32                                                                      Setup v{#= installer_build_number} built on {#= installer_build_date}


[Files]
Source: ..\..\bin\Release\Assistant.exe; DestDir: {app}; Flags: ignoreversion
Source: ..\..\bin\Release\base.txt; DestDir: {app}; Flags: ignoreversion
Source: ..\..\bin\Release\CHANGELOG.txt; DestDir: {app}; Flags: ignoreversion
Source: ..\..\bin\Release\Help.htm; DestDir: {app}; Flags: ignoreversion
Source: ..\..\bin\Release\LICENSE.txt; DestDir: {app}; Flags: ignoreversion
Source: ..\..\bin\Release\kprocesshacker.sys; DestDir: {app}; Flags: ignoreversion; Check: NOT Is64BitInstallMode()
Source: ..\..\bin\Release\NProcessHacker.dll; DestDir: {app}; Flags: ignoreversion; Check: NOT Is64BitInstallMode()
Source: ..\..\bin\Release\NProcessHacker64.dll; DestName: NProcessHacker.dll; DestDir: {app}; Flags: ignoreversion; Check: Is64BitInstallMode()
Source: ..\..\bin\Release\ProcessHacker.exe; DestDir: {app}; Flags: ignoreversion
Source: ..\..\bin\Release\README.txt; DestDir: {app}; Flags: ignoreversion
Source: ..\..\bin\Release\structs.txt; DestDir: {app}; Flags: ignoreversion
Source: Icons\uninstall.ico; DestDir: {app}; Flags: ignoreversion


[Tasks]
Name: desktopicon; Description: {cm:CreateDesktopIcon}; GroupDescription: {cm:AdditionalIcons}
Name: desktopicon\user; Description: {cm:tsk_currentuser}; GroupDescription: {cm:AdditionalIcons}; Flags: exclusive
Name: desktopicon\common; Description: {cm:tsk_allusers}; GroupDescription: {cm:AdditionalIcons}; Flags: unchecked exclusive
Name: quicklaunchicon; Description: {cm:CreateQuickLaunchIcon}; GroupDescription: {cm:AdditionalIcons}; OnlyBelowVersion: 0,6.01; Flags: unchecked

Name: startup_task; Description: {cm:tsk_startupdescr}; GroupDescription: {cm:tsk_startup}; Check: StartupCheck(); Flags: unchecked checkablealone
Name: startup_task\minimized; Description: {cm:tsk_startupdescrmin}; GroupDescription: {cm:tsk_startup}; Check: StartupCheck(); Flags: unchecked
Name: remove_startup_task; Description: {cm:tsk_removestartup}; GroupDescription: {cm:tsk_startup}; Check: NOT StartupCheck(); Flags: unchecked

Name: create_KPH_service; Description: {cm:tsk_createKPHservice}; GroupDescription: {cm:tsk_other}; Check: NOT KProcessHackerStateCheck() AND NOT Is64BitInstallMode(); Flags: unchecked dontinheritcheck
Name: delete_KPH_service; Description: {cm:tsk_deleteKPHservice}; GroupDescription: {cm:tsk_other}; Check: KProcessHackerStateCheck() AND NOT Is64BitInstallMode(); Flags: unchecked dontinheritcheck

Name: reset_settings; Description: {cm:tsk_resetsettings}; GroupDescription: {cm:tsk_other}; Check: SettingsExistCheck(); Flags: unchecked checkablealone

Name: set_default_taskmgr; Description: {cm:tsk_setdefaulttaskmgr}; GroupDescription: {cm:tsk_other}; Check: PHDefaulTaskmgrCheck(); Flags: unchecked dontinheritcheck
Name: restore_taskmgr; Description: {cm:tsk_restoretaskmgr}; GroupDescription: {cm:tsk_other}; Check: NOT PHDefaulTaskmgrCheck(); Flags: unchecked dontinheritcheck


[Icons]
Name: {group}\Process Hacker; Filename: {app}\ProcessHacker.exe; Comment: Process Hacker {#= simple_app_version}; WorkingDir: {app}; IconFilename: {app}\ProcessHacker.exe; IconIndex: 0
Name: {group}\{cm:sm_help}\{cm:sm_changelog}; Filename: {app}\CHANGELOG.txt; Comment: {cm:sm_com_changelog}; WorkingDir: {app}
Name: {group}\{cm:sm_help}\{cm:sm_helpfile}; Filename: {app}\Help.htm; Comment: {cm:sm_helpfile}; WorkingDir: {app}
Name: {group}\{cm:sm_help}\{cm:sm_readmefile}; Filename: {app}\README.txt; Comment: {cm:sm_com_readmefile}; WorkingDir: {app}
Name: {group}\{cm:sm_help}\{cm:ProgramOnTheWeb,Process Hacker}; Filename: http://processhacker.sourceforge.net/; Comment: {cm:ProgramOnTheWeb,Process Hacker}
Name: {group}\{cm:UninstallProgram,Process Hacker}; Filename: {uninstallexe}; IconFilename: {app}\uninstall.ico; Comment: {cm:UninstallProgram,Process Hacker}; WorkingDir: {app}

Name: {commondesktop}\Process Hacker; Filename: {app}\ProcessHacker.exe; Tasks: desktopicon\common; Comment: Process Hacker {#= simple_app_version}; WorkingDir: {app}; IconFilename: {app}\ProcessHacker.exe; IconIndex: 0
Name: {userdesktop}\Process Hacker; Filename: {app}\ProcessHacker.exe; Tasks: desktopicon\user; Comment: Process Hacker {#= simple_app_version}; WorkingDir: {app}; IconFilename: {app}\ProcessHacker.exe; IconIndex: 0
Name: {userappdata}\Microsoft\Internet Explorer\Quick Launch\Process Hacker; Filename: {app}\ProcessHacker.exe; Tasks: quicklaunchicon; Comment: Process Hacker {#= simple_app_version}; WorkingDir: {app}; IconFilename: {app}\ProcessHacker.exe; IconIndex: 0


[InstallDelete]
; Remove files from the install folder which are not needed anymore
Type: files; Name: {app}\ProcessHacker.exe.config
Type: files; Name: {app}\HACKING.txt
Type: files; Name: {app}\psvince.dll
Type: files; Name: {app}\Homepage.url
Type: files; Name: {app}\kprocesshacker.sys; Check: Is64BitInstallMode()

Type: files; Name: {userdesktop}\Process Hacker.lnk; Check: NOT IsTaskSelected('desktopicon\user')
Type: files; Name: {commondesktop}\Process Hacker.lnk; Check: NOT IsTaskSelected('desktopicon\common')

; Remove other languages' shortcuts in Start Menu
Type: files; Name: {group}\Process Hacker's Readme file.lnk
Type: files; Name: {group}\Process Hacker on the Web.url
Type: files; Name: {group}\Uninstall Process Hacker.lnk
Type: files; Name: {group}\Help and Support\Process Hacker on the Web.url
Type: files; Name: {group}\Help and Support\Change Log.lnk
Type: files; Name: {group}\Help and Support\Changelog.lnk
Type: files; Name: {group}\Help and Support\Process Hacker's Help.lnk
Type: files; Name: {group}\Help and Support\ReadMe File.lnk
Type: files; Name: {group}\Help and Support\ReadMe.lnk
Type: dirifempty; Name: {group}\Help and Support

Type: files; Name: {group}\������ �������� ��� Process Hacker.lnk
Type: files; Name: {group}\�� Process Hacker ��� Internet.url
Type: files; Name: {group}\������������� ��� Process Hacker.lnk
Type: files; Name: {group}\������� ��� ����������\�� Process Hacker ��� Internet.url
Type: files; Name: {group}\������� ��� ����������\�������� ��������.lnk
Type: files; Name: {group}\������� ��� ����������\������ �������� ��� Process Hacker.lnk
Type: files; Name: {group}\������� ��� ����������\������ ReadMe.lnk
Type: dirifempty; Name: {group}\������� ��� ����������

Type: filesandordirs; Name: {localappdata}\wj32; Tasks: reset_settings


[Registry]
Root: HKLM; Subkey: SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\taskmgr.exe; Flags: uninsdeletekeyifempty dontcreatekey
Root: HKCU; SubKey: Software\Microsoft\Windows\CurrentVersion\Run; ValueType: string; ValueName: Process Hacker; ValueData: """{app}\ProcessHacker.exe"""; Tasks: startup_task; Flags: uninsdeletevalue
Root: HKCU; SubKey: Software\Microsoft\Windows\CurrentVersion\Run; ValueType: string; ValueName: Process Hacker; ValueData: """{app}\ProcessHacker.exe"" -m"; Tasks: startup_task\minimized; Flags: uninsdeletevalue
Root: HKCU; SubKey: Software\Microsoft\Windows\CurrentVersion\Run; ValueName: Process Hacker; Tasks: remove_startup_task; Flags: deletevalue uninsdeletevalue
Root: HKLM; Subkey: SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\taskmgr.exe; ValueType: string; ValueName: Debugger; ValueData: """{app}\ProcessHacker.exe"""; Tasks: set_default_taskmgr
Root: HKLM; Subkey: SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\taskmgr.exe; ValueType: string; ValueName: Debugger; ValueData: """{app}\ProcessHacker.exe"""; Flags: uninsdeletevalue; Check: NOT PHDefaulTaskmgrCheck()
Root: HKLM; Subkey: SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\taskmgr.exe; ValueName: Debugger; Tasks: restore_taskmgr reset_settings; Flags: deletevalue uninsdeletevalue; Check: NOT PHDefaulTaskmgrCheck()

; Windows Error Reporting keys
Root: HKLM; Subkey: SOFTWARE\Microsoft\Windows\Windows Error Reporting\LocalDumps; ValueType: none; Flags: uninsdeletekeyifempty createvalueifdoesntexist; MinVersion: 0,6.0.6001
Root: HKLM; Subkey: SOFTWARE\Microsoft\Windows\Windows Error Reporting\LocalDumps\ProcessHacker.exe; ValueType: none; Flags: uninsdeletekey; MinVersion: 0,6.0.6001
Root: HKLM; Subkey: SOFTWARE\Microsoft\Windows\Windows Error Reporting\LocalDumps\ProcessHacker.exe; ValueType: dword; ValueName: DumpCount; ValueData: 5; Flags: uninsdeletevalue; MinVersion: 0,6.0.6001
Root: HKLM; Subkey: SOFTWARE\Microsoft\Windows\Windows Error Reporting\LocalDumps\ProcessHacker.exe; ValueType: expandsz; ValueName: DumpFolder; ValueData: {sd}\ProgramData\wj32; Flags: uninsdeletevalue; MinVersion: 0,6.0.6001
Root: HKLM; Subkey: SOFTWARE\Microsoft\Windows\Windows Error Reporting\LocalDumps\ProcessHacker.exe; ValueType: dword; ValueName: DumpType; ValueData: 1; Flags: uninsdeletevalue; MinVersion: 0,6.0.6001


[Run]
Filename: {win}\Microsoft.NET\Framework\v2.0.50727\ngen.exe; Parameters: "install ""{app}\ProcessHacker.exe"""; StatusMsg: {cm:msg_optimizingperformance}; Flags: runhidden runascurrentuser skipifdoesntexist

Filename: {app}\ProcessHacker.exe; Description: {cm:LaunchProgram,Process Hacker}; Flags: nowait postinstall skipifsilent runascurrentuser
Filename: http://processhacker.sourceforge.net/; Description: {cm:run_visitwebsite}; Flags: nowait postinstall skipifsilent shellexec runascurrentuser unchecked


[UninstallDelete]
Name: {app}\Homepage.url; Type: files
Name: {sd}\ProgramData\wj32\*.dmp; Type: files; MinVersion: 0,6.0.6001
Name: {sd}\ProgramData\wj32; Type: dirifempty; MinVersion: 0,6.0.6001


[Code]
// Create a mutex for the installer
const installer_mutex_name = 'process_hacker_setup_mutex';


// Check if Process Hacker is configured to run on startup in order to control
// startup choice from within the installer
function StartupCheck(): Boolean;
begin
  Result := True;
  if RegValueExists(HKCU, 'Software\Microsoft\Windows\CurrentVersion\Run', 'Process Hacker') then
  Result := False;
end;


// Check if Process Hacker's settings exist
function SettingsExistCheck(): Boolean;
begin
  Result := False;
  if DirExists(ExpandConstant('{localappdata}\wj32\')) then
  Result := True;
end;


// Check if Process Hacker is set as the default Task Manager for Windows
function PHDefaulTaskmgrCheck(): Boolean;
var
  svalue: String;
begin
  Result := True;
  if RegQueryStringValue(HKLM,
  'SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\taskmgr.exe', 'Debugger', svalue) then begin
    if svalue = (ExpandConstant('"{app}\ProcessHacker.exe"')) then
    Result := False;
  end;
end;


// Check if KProcessHacker is installed as a service
function KPHServiceCheck(): Boolean;
var
  dvalue: DWORD;
begin
  Result := False;
  if RegQueryDWordValue(HKLM, 'SYSTEM\CurrentControlSet\Services\KProcessHacker', 'Start', dvalue) then begin
    if dvalue = 1 then
    Result := True;
  end;
end;


// Check if Process Hacker's settings exist
function KProcessHackerStateCheck(): Boolean;
begin
  Result := False;
  if KPHServiceCheck AND IsServiceRunning('KProcessHacker') then
  Result := True;
end;


procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssInstall then begin
   if KProcessHackerStateCheck then begin
    StopService('KProcessHacker');
   end;
  if IsTaskSelected('delete_KPH_service') then begin
    StopService('KProcessHacker');
    RemoveService('KProcessHacker');
  end;
  end;
  if CurStep = ssPostInstall then begin
   if KPHServiceCheck AND NOT IsTaskSelected('delete_KPH_service') then begin
    StartService('KProcessHacker');
   end;
    if IsTaskSelected('create_KPH_service') then begin
     StopService('KProcessHacker');
     RemoveService('KProcessHacker');
     InstallService(ExpandConstant('{app}\kprocesshacker.sys'),'KProcessHacker','KProcessHacker','KProcessHacker driver',SERVICE_KERNEL_DRIVER,SERVICE_SYSTEM_START);
     StartService('KProcessHacker');
    end;
  end;
end;


Procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  // When uninstalling ask user to delete Process Hacker's logs and settings
  // based on whether these files exist only
  if CurUninstallStep = usUninstall then begin
  if DirExists(ExpandConstant('{localappdata}\wj32\'))
  or fileExists(ExpandConstant('{app}\Process Hacker Log.txt'))
  or fileExists(ExpandConstant('{userdocs}\Process Hacker.txt'))
  or fileExists(ExpandConstant('{userdocs}\Process Hacker.log'))
  or fileExists(ExpandConstant('{userdocs}\Process Hacker.csv'))
  or fileExists(ExpandConstant('{userdocs}\Process Hacker Log.txt'))
  or fileExists(ExpandConstant('{userdocs}\CSR Processes.txt'))
  or fileExists(ExpandConstant('{app}\scratchpad.txt'))then begin
    if MsgBox(ExpandConstant('{cm:msg_DeleteLogSettings}'),
     mbConfirmation, MB_YESNO or MB_DEFBUTTON2) = IDYES then begin
      DelTree(ExpandConstant('{localappdata}\wj32\'), True, True, True);
      DeleteFile(ExpandConstant('{app}\Process Hacker.txt'));
      DeleteFile(ExpandConstant('{app}\Process Hacker.log'));
      DeleteFile(ExpandConstant('{app}\Process Hacker.csv'));
      DeleteFile(ExpandConstant('{app}\Process Hacker Log.txt'));
      DeleteFile(ExpandConstant('{app}\CSR Processes.txt'));
      DeleteFile(ExpandConstant('{userdocs}\Process Hacker Log.txt'));
      DeleteFile(ExpandConstant('{userdocs}\CSR Processes.txt'));
      DeleteFile(ExpandConstant('{app}\scratchpad.txt'));
      end;
    end;
  end;
end;


function InitializeSetup(): Boolean;

// Check if .NET Framework 2.0 is installed and if not offer to download it
var
  ErrorCode: Integer;
  NetFrameWorkInstalled : Boolean;
  Result1 : Boolean;
begin
  // Create a mutex for the installer and if it's already running then expose a message and stop installation
  if CheckForMutexes(installer_mutex_name) then begin
  if not WizardSilent() then
    MsgBox(ExpandConstant('{cm:msg_SetupIsRunningWarning}'), mbCriticalError, MB_OK);
    Result := False;
  end
  else begin
  CreateMutex(installer_mutex_name);

  NetFrameWorkInstalled := RegKeyExists(HKLM,'SOFTWARE\Microsoft\.NETFramework\policy\v2.0');
  if NetFrameWorkInstalled then begin
    Result := True;
    end
    else begin
      Result1 := MsgBox(ExpandConstant('{cm:msg_asknetdown}'), mbCriticalError, MB_YESNO or MB_DEFBUTTON1) = IDYES;
    if Result1 = False then begin
      Result := False;
      end
      else begin
      Result := False;
      ShellExec('open', 'http://download.microsoft.com/download/5/6/7/567758a3-759e-473e-bf8f-52154438565a/dotnetfx.exe',
      '','',SW_SHOWNORMAL,ewNoWait,ErrorCode);
      end;
    end;
  end;
end;


function InitializeUninstall(): Boolean;
begin
  Result := True;
  if CheckForMutexes(installer_mutex_name) then begin
    if not WizardSilent() then
      MsgBox(ExpandConstant('{cm:msg_SetupIsRunningWarning}'), mbCriticalError, MB_OK);
      Result := False;
    end
    else begin
    CreateMutex(installer_mutex_name);

    StopService('KProcessHacker');
    RemoveService('KProcessHacker');
  end;
end;
