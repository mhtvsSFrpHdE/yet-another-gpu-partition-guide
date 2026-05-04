@REM Your game start shortcut
@REM Example of Steam games:
@REM set gameLnk=".\Euro Truck Simulator 2.url"
set gameLnk=".\XIVLauncher.lnk"

@REM Your game process name, usually is .exe file without extension name
@REM For example, ffxiv_dx11.exe would be ffxiv_dx11
set gameProcessName="ffxiv_dx11"

@REM Target display Hz
set refreshRateSwitchTo=120
set refreshRateSwitchDelay=10

@REM How many time passed from your game process starts, to render first frame 3D content seconds
@REM Too short may still cause game crash
set vulkanInitDelay=30

cd /d %~dp0
displayswitch /extend
explorer %gameLnk%

timeout /t %refreshRateSwitchDelay%
powershell .\SetRefreshReate.ps1 %refreshRateSwitchTo%

powershell .\WaitGameStart.ps1 %gameProcessName%

timeout /t %vulkanInitDelay%
displayswitch /internal

powershell .\WaitGameStop.ps1 %gameProcessName%
displayswitch /extend
