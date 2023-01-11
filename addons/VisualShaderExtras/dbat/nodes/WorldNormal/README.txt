World Normal Mixing
==
I got the idea and code from Arnklit here:
https://www.youtube.com/watch?v=OvHNg4-Ueng

The process gives a much better mix between textures where normal maps are involved.

The main code is broken into three stages
1. Normal add z 
2. Normal mask
3. Mask blend

Each of those are useful in their own right, so I made them all separate nodes too.
However this node (the TempVisualShaderNodeWorldNormalMapMixer) does all that in one go.
