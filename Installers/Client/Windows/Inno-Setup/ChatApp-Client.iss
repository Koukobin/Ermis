; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define MyAppName "ChatApp-Client"
#define MyAppVersion "1.0"
#define MyAppExeName "ChatAppClient.exe"
#define MyAppIcon "ChatApp-Client.ico"
#define MyAppLicence "ChatApp-Client\LICENCE.txt"
#define MyAppFolder "ChatApp-Client"

[Setup]
; NOTE: The value of AppId uniquely identifies this application. Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{1DDFF5D8-E1CE-4E88-9542-BE34F9D648DE}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
DefaultDirName={autopf}\{#MyAppName}
DisableDirPage=yes
ChangesAssociations=yes
DisableProgramGroupPage=yes
LicenseFile={#MyAppLicence}
; Comment the following line to run in administrative install mode (install for all users.)
PrivilegesRequired=lowest
OutputBaseFilename=mysetup
SetupIconFile={#MyAppIcon}
Compression=lzma
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{#MyAppFolder}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

