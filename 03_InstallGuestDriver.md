## Install driver
Although Nvidia Control Panel can't be installed directly  
but use Nvidia Profile Inspector will possible

First time install, run `C:\GpuDriver\install_with_data.ps1` with admin permission  
On upgrade driver, run `C:\GpuDriver\install.ps1` to skip `C:\ProgramData\NVIDIA Corporation`

## Finish
Reboot now, after reboot it should work  
Once you succussfully configured GPU Partition  
You **MUST** record your Windows version and driver version like this
- Windows 11 OS Build 26100.2033
- Nvidia 572.16

You'll need them if GPU Partition break by Windows or driver update  
so you can perform a downgrade to known good version combination

It's recommended to keep GpuDriver folder copied to guest OS for uninstall  
at least keep `ps1` files named `uninstall...` so you can uninstall files before upgrade driver

See "Troubleshoot - Emergency recovery" for more information, and about downgrade
