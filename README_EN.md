# Switch Tablet Mode
## Language
[Chinese Version | 中文说明](README.md)
## Uses
Used to switch between **tablet mode** and **normal PC mode** on the Windows platform

-> Since Windows 11 is currently recognized by itself, when it is judged to be a tablet device, it is forced to stay in tablet mode, and cannot be manually switched to ordinary PC mode. This script allows the user to switch manually.
## Compatibility
- Compatible with Windows 11 platform (theoretically also supports Windows 10, not yet tested)
- Compatible with x86 platforms
- Compatible with Arm platforms
## Usage
Download the cmd file in this project, or copy its contents and paste them into text, and save it as cmd/bat file with ANSI encoding for administrator to run
## Principle
Switch the tablet mode by controlling the value of the registry key `HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl\ConvertibleSlateMode`.
## Features
- Added recognition to whether the current is running as an administrator, if yes it continues, otherwise prompt and exit after 5 seconds
- Added recognition of whether the current device is a tablet device, if yes, continue to run, otherwise the alarm (can still be forced, note: this does not give you touch and screen auto-rotation!)
- Added recognition of current mode
- Added recognition of whether to restart the Explorer service after execution (by default, the Explorer does not need to be restarted to take effect immediately)

## Comments
### Tablet mode
- Optimized touch controls, especially multi-touch
- Explorer: File Selection uses a checkbox mode
- Provide keyboard connection recognition: use an external keyboard if there is connected, and pull up the on-screen keyboard if there is no connection
- Provides gravity rotation control (if hardware support)
- Status bar auto-hide (different from PC mode auto-hide style)
- etc,.
### Normal PC mode
- That is, the familiar desktop and notebook Windows control mode
- On tablet devices: the on-screen keyboard cannot be automatically pulled up, the touch operation is inconvenient, etc
