# FFXIV - Troubleshoot
**7.3**  
After 7.3 update, seems game break compatibility with 10 series and old graphics card  
even on non virtual, real PC, game won't start  
for 1080 Ti, latest dxvk 2.7 can be used to start the game, or update graphics driver may help  
for 760, dxvk 1.3 can be used to start the game, nvidia driver support has ended

# FFXIV - Easiest setup
- Press Win+P shortcut, switch to PC screen only  
assume you've already set virtual display adapter as primary monitor  
this will leave primary monitor on and Hyper-V video off
- Open nvidiaProfileInspector, locate `Final Fantasy XIV: A Realm Reborn`, change vertical sync to Force off  
The game has vertical sync on by default and no options to turn off
but we'll do vsync on Moonlight side
- You can use either RivaTuner or in-game frame limiter    
Nvidia driver frame limiter v3 doesn't work  
in-game 60 FPS result in 59 FPS, RivaTuner did 60 FPS
- Game

You can use optiscaler directly in this setup since it's raw DirectX 11

The following guide is for advanced setup
- Dual monitor (preserve OpenGL)
- dxvk / optiscaler (Vulkan and FSR 3 mod)

# FFXIV - Dual monitor
## Optimizations for windowed games
- Settings - System - Display - Graphics - Optimizations for windowed games, change to On
- Custom settings for applications - Find FINAL FANTASY XIV - Expand menu - Optimizations for windowed games, change to On

By default even global on, Windows think it should be off for this game  
I discover or assume with optimization on, DXGI can capture all frames even vertical sync is off  
without windowed optimization, FFXIV can still run at 60 FPS but visually drop a lot frames

In dual monitor, this mode prevents corrupted image in motion

## Vertical sync
- Open nvidiaProfileInspector, locate `Final Fantasy XIV: A Realm Reborn`, change vertical sync to Force off  
The game has vertical sync on by default and no options to turn off, but we'll do vsync on Moonlight side
- You can use either RivaTuner or in-game frame limiter    
Nvidia driver frame limiter v3 doesn't work  
in-game 60 FPS result in 59 FPS, RivaTuner did 60 FPS

# FFXIV dxvk / optiscaler
optiscaler plus dxvk Vulkan API, see `Tools\Vulkan`

If game crashed without any information dialog  
Try remove every config in `dxvk.conf` only keep `dxvk.enableAsync` line  
Seems GPU spoofing no longer works on FFXIV 7.3  
and you may running out of luck to enable DLSS and result in TSCMAA+Camera jitter

## dxvk.conf reference
Place this file together with dxvk dlls aside game exe
```
dxvk.enableAsync=true
dxgi.customVendorId = 10de
dxgi.hideAmdGpu = True
dxgi.hideNvidiaGpu = False
dxgi.customDeviceId = 2684
dxgi.customDeviceDesc = "NVIDIA GeForce RTX 4090"
```
- `enableAsync` add support for [dxvk-gplasync](https://gitlab.com/Ph42oN/dxvk-gplasync)
- `customVendorId` to `customDeviceDesc` spoof graphics card model so game think there is DLSS available
