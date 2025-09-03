@REM Your game start shortcut
set gameLnk=".\XIVLauncherCN.lnk"

@REM Your game process name, usually is .exe file without extension name
@REM For example, ffxiv_dx11.exe would be ffxiv_dx11
set gameProcessName="ffxiv_dx11"

@REM How many time passed from your game process starts, to render first frame 3D content seconds
@REM Too short may still cause game crash
set vulkanInitDelay=20

cd /d %~dp0
displayswitch /extend

explorer %gameLnk%

powershell .\WaitGameStart.ps1 %gameProcessName%
timeout /t %vulkanInitDelay%
displayswitch /internal

powershell .\WaitGameStop.ps1 %gameProcessName%
displayswitch /extend
