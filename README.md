# Yet another GPU Partition guide
You got tons of automatically scripts, they focus on automatically but often hard to explain why it will work.  
Some of them contains magic values and wrong argument only work for their PC.

Instead of a script, this repository focus on important steps and why.

## Usage
`.txt` file are actually PowerShell commands with comments.  
You can copy and paste, run in a admin permission powershell window directly.  
Change arguments before paste into powershell window.

## Verify gpu compatibility
Install Windows feature "Windows Sandbox", open Sandbox and check if the sandbox is GPU accelerated.  
If true, you gpu or driver verson does support GPU partition.  
Otherwise give up and swap to newer GPU.

## Reference
https://gist.github.com/ThioJoe/56e1c4951be2c1a19b126ec619ec26c4  
https://docs.nvidia.com/vgpu/latest/pdf/grid-vgpu-user-guide.pdf (page 29)
