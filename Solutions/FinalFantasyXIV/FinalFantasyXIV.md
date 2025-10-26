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
optiscaler plus dxvk Vulkan API

## Optimizations for windowed games
You don't need this option in Vulkan in the end  
although it did prevents corrupted image in dual monitor  
but with Vulkan and dual monitor, video can't be reliable recorded by DXGI  
result in single monitor setup

## Vertical sync
- Open nvidiaProfileInspector, locate `Final Fantasy XIV: A Realm Reborn`, change vertical sync to Force off  
The game has vertical sync on by default and no options to turn off, but we'll do vsync on Moonlight side
- In RivaTuner, set 60 FPS limit for FFXIV, don't use in-game frame limiter  
Nvidia driver frame limiter v3 doesn't work  
In-game frame limiter incompatible with Hyper-V virtual monitor or virtual display adapter
result in corrupted image in motion (like moving camera)
- Press Win+P shortcut, ensure running in PC screen only mode  
change refresh rate to 60*2=120 Hz (1)
- Check RTSS settings, don't use NVIDIA Reflex as FPS limiter, just use default async mode

(1): I notice that since FFXIV 7.3 / dxvk-gplasync-v2.7.1-1  
FFXIV with dxvk has image tearing even on screenshot, no matter how vsync setting is  
tearing happens on image level instead of monitor level  
Set virtual monitor refresh rate double of FPS limiter resolved this  
These issue didn't exist on FFXIV 7.1

## How to start the game
- Press Win+P shortcut, ensure running in Extend mode
- Start the game (1)
- After game start, press Win+P, switch display mode from Extend to PC screen only  
assume you've already set virtual display adapter as primary monitor  
this will leave primary monitor on and Hyper-V video off
- Check and ensure virtual display adapter in PC screen only mode running at 60*2=120 Hz  
which is, regularly in dual monitor setup it is run at 90 Hz, but now same as game FPS limiter

With all these setup, now game will run and capture / stream smoothly at 60 FPS, and you have dxvk and optiscaler

Do this quick with scripts under `Tools\Vulkan`

(1): If game crashed without any information dialog  
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
