### CPU usage
Seems battleye will complain about CPU usage too high (98% or above on online mode loading screen)

If kicked by battleye when try to join online, try join story mode first, then enter online mode  
to prevent online and open world load at same time to reduce CPU usage

Or, allocate more CPU core / thread.  
For example, AMD 8400F has total 6 core 12 thread on host
- If I only allocate 6 core (6 core 6 thread) to virtual machine, will be kicked by battleye  
(3 core 6 thread doesn't kick, maybe because after became skilled players I started to join story mode by first)
- If I allocate 8 core (4 core 8 thread), battleye allow me to play online
- If I allocate 6 core (but in 3 core 6 thread), battleye allow me to play online even if I don't use story mode hack
it's a bit strange, but you may also give virtual machine hyper thread like this to pass battleye check

## Nested virtualization
Simply enable nested virtualization does not cause BE kick
```
Set-VMProcessor -VMName <VMName> -ExposeVirtualizationExtensions $true
```
However, if install Windows feature "Windows Sandbox" inside guest VM,  
even no sandbox running, still 100% trigger battleye kick

Solution is uninstall Windows Sandbox
