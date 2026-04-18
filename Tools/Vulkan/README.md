# Usage
1. Copy `StartGame.bat` and name it to you want
1. Edit copied file with `notepad.exe`, modify shortcut path to your game
1. Modify `gameLnk` to shortcut of your game or launcher, can be regular `.lnk` or `.url` for Steam games
1. Modify `gameProcessName` to game acutal process name after launch
1. Modify `vulkanInitDelay` if necessary
1. Save, double click on your file to check result

# About DXVK and image corrupt or tearing
A solution is exist, some steps has integrated into `Star Game.bat`, here to explain what has been done

1. Use Desktop duplication capture API
1. Nvidia control panel vsync settings to "Use 3D application settings", in game vsync settings to off, frame limiter to off
1. If use RTSS, make profile "eurotrucks2.exe", per profile settings, frame limiter 60 fps, frame limiter mode NVIDIA Reflex, Use Microsoft Detours API hooking set to on
1. Switch monitor mode to Extend (Win + P keyboard shortcut), turn on Microsoft Hyper-V Video + Virtual Display Driver together so Vulkan apps can run
1. Set Virtual Display Driver to 60 Hz, then set to 120 Hz, then set to 60 Hz, then set to whatever you want
1. Start game
1. After enter the game, switch monitor mode to PC screen only, notice that vulkan apps can't start without Microsoft Hyper-V Video but able to continue to run on turn off Hyper-V video after game window is created
1. Image corruption gone and looks pretty smooth
1. Vertical sync is done on Moonlight client so there is no tearing

Refresh rate change can be done at any time after desktop duplication capture session started  
On each session start, need to toggle refresh rate to workaround Vulkan / DXVK image corrupt or tearing issue
