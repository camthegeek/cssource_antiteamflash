# Anti Team Flash Plugin for Counter-Strike: Source

A SourceMod plugin for Counter-Strike: Source that prevents teammates from being flashed by friendly flashbangs.

## Features

- Prevents teammates from being blinded by friendly flashbangs
- Notifies the thrower when they attempt to flash a teammate
- Notifies the protected player when they've been saved from a team flash
- Includes admin notifications
- Configurable logging options

## Installation

1. Make sure you have SourceMod installed on your CS:S server
2. Download the plugin files
3. Upload the plugin file to your server's `css/addons/sourcemod/plugins/` directory
4. Restart your server or load the plugin using `sm plugins load camsAntiTeamFlash`

## Configuration

The following ConVars can be added to your `server.cfg` or changed in-game:

- `sm_log_teamflash` (Default: 1)
  - Enables/disables logging of team flash incidents to SourceMod logs
  - Set to 1 to enable, 0 to disable

- `sm_debug_teamflash` (Default: 0)
  - Enables detailed debug logging for team flashes
  - Set to 1 to enable, 0 to disable

## Messages

Players will see the following notifications:

- Thrower: "[Anti-TeamFlash] You flashed teammate PlayerName!"
- Victim: "[Anti-TeamFlash] Protected from PlayerName's flashbang"
- Admins: "[Anti-TeamFlash] PlayerName flashed teammate VictimName"


## Requirements

- SourceMod 1.12 or higher
- Counter-Strike: Source


## Building from Source

1. Ensure you have the SourceMod scripting tools installed
2. Compile `camsAntiTeamFlash.sp` using the spcomp compiler
3. Place the compiled .smx file in your plugins directory

## Support

For issues or feature requests, please open an issue on the GitHub repository.
