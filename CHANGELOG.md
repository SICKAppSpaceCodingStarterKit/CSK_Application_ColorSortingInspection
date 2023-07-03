# Changelog
All notable changes to this project will be documented in this file.

## Release 0.6.0

### Improvements
- Updated CSK modules (check README)
- Added icon to UI
- Link to MultiRemoteCamera module UIs updated
- Using recursive helper functions to convert Container <-> Lua table
- Update to EmmyLua annotations
- Usage of lua diagnostics
- Documentation updates

### Bugfix
- Fixed wrong title within iFrame html files

## Release 0.5.0

### Improvements
- Using internal moduleName variable instead of _APPNAME

## Release 0.4.0

### New features
- Making use of dynamic viewerIDs -> only one single viewer for all instances

### Improvements
- Using iFrames instead of copying UIs of other modules
- TCP/IP Output includes instance source of result
- Configure TCPIP result output by app reboot
- Check at app start if all modules are available
- Naming of UI elements and adding some mouse over info texts
- Appname added to log messages
- Option to hide info text in UI
- Using default parameter names
- Handling of "loadOnReboot"
- Minor edits, docu, logs

### Bugfix
- Removed application "Jobs" as they were leading to misunderstandings compared to modules parameters
- Deactivation of result output via TCPIP did not work

## Release 0.3.0

### New features
- Optionally hide content related to CSK_UserManagement

### Improvements
- Loading only required APIs ('LuaLoadAllEngineAPI = false') -> less time for GC needed
- Update of helper funcs to support 4-dim tables for PersistentData
- Moved asset content into module folder
- Add info about camera image queue to application UI
- Changed order within UI navigation (Login more on top)
- Minor code edits / docu updates

### Bugfix
- Adding instance via app made problem with new modules of CSK_MultiRemoteCamera + CSK_MultiColorSelection (no argument needed anymore)
- LoadOnReboot was set to false when changing instance in application UI
- When instance change on camera page, application UI showed wrong combination of instance + job

## Release 0.2.0

### Improvements
- Docu added

## Release 0.1.0
- Initial commit