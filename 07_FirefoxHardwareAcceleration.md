# Background
Firefox GPU blocklist is hard-coded and can't be disabled by using `about:config` hack like `gfx.webgpu.ignore-blocklist`  
Instead GPU spoofing works

[How to force-enable blocked graphics features](https://wiki.mozilla.org/Blocklisting/Blocked_Graphics_Drivers)  
[Allow spoofing GfxInfo and circumventing the blocklist on Windows](https://bugzilla.mozilla.org/show_bug.cgi?id=604771)

# Steps
Open Firefox on host PC, go to `about:config`, find `GPU #1` on page, record these values:
- Vendor ID, example `0x10de`
- Device ID, example `0x1b06`
- Driver Version, example `32.0.15.7216`

Go to guest OS, create environment variables and its value should exact same record from host OS
- `MOZ_GFX_SPOOF_VENDOR_ID`, value from Vendor ID, example `0x10de`
- `MOZ_GFX_SPOOF_DEVICE_ID`, value from Device ID, example `0x1b06`
- `MOZ_GFX_SPOOF_DRIVER_VERSION`, value from Driver Version, example `32.0.15.7216`

Restart Firefox, go to `about:support` and verify using `WebRender`, no longer `WebRender (Software)`
