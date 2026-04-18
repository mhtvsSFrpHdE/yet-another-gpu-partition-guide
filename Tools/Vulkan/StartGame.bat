@REM Your game start shortcut
set gameLnk=".\XIVLauncherCN.lnk"

@REM Your game process name, usually is .exe file without extension name
@REM For example, ffxiv_dx11.exe would be ffxiv_dx11
set gameProcessName="ffxiv_dx11"

@REM Switch to any display Hz then switch back
@REM Fix dxvk image corrouption on Windows 11 25H2 26100.7840
set refreshRateSwitchTo=60
set refreshRateSwitchBack=120
set refreshRateSwitchDelay=10

@REM How many time passed from your game process starts, to render first frame 3D content seconds
@REM Too short may still cause game crash
set vulkanInitDelay=20

cd /d %~dp0
displayswitch /extend

explorer %gameLnk%

timeout /t %refreshRateSwitchDelay%
powershell .\SetRefreshReate.ps1 %refreshRateSwitchTo%

powershell .\WaitGameStart.ps1 %gameProcessName%

timeout /t %vulkanInitDelay%
displayswitch /internal

timeout /t %refreshRateSwitchDelay%
powershell .\SetRefreshReate.ps1 %refreshRateSwitchBack%

powershell .\WaitGameStop.ps1 %gameProcessName%
displayswitch /extend

timeout /t %refreshRateSwitchDelay%
powershell .\SetRefreshReate.ps1 %refreshRateSwitchBack%
