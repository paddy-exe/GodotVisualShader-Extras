<div id="header" align="center">
  <img src="addons/VisualShaderExtras/AddonAssets/VisualShaderExtras-Logo.png" width="250"/>
</div>
<div id="badges" align="center">
  <a href="https://ko-fi.com/flamelizard">
    <img src="https://img.shields.io/badge/Support my work-red?style=for-the-badge&logo=kofi&logoColor=white" alt="Ko-Fi Badge"/>
  </a>
  <a href="https://twitter.com/patrick_exe">
    <img src="https://img.shields.io/badge/Twitter-blue?style=for-the-badge&logo=twitter&logoColor=white" alt="Twitter Badge"/>
  </a>
  <a href="https://mastodon.gamedev.place/@flamelizard">
    <img src="https://img.shields.io/badge/Mastodon-purple?style=for-the-badge&logo=mastodon&logoColor=white" alt="Mastodon Badge"/>
  </a>
</div>

# GodotVisualShader-Extras 3.x✨

A Visual Shader Node Add-On for the Godot Engine

The icon was kindly supplied by [LucyLavend](https://youtube.com/LucyLavend)

## Provided Nodes
<div align="center">
  <img src="addons/VisualShaderExtras/AddonAssets/BlendingModes-Showcase.png" width="800"/>
</div>

- Blending Modes (taken from Krita Docs and other sources)
    - Darker Colors
    - Exclusion
    - Gamma Dark
    - Gamma Illumination
    - Gamma Light
    - Hard Mix
    - Lighter Color
    - Linear Burn
    - Linear Light
    - Luminosity
    - Pin Light
    - Vivid Light

<div align="center">
  <img src="addons/VisualShaderExtras/AddonAssets/Shapes-Showcase.png" width="800"/>
</div>

- Shapes (Signed Distance Fields)
    - Box
    - Circle
    - Rounded Box
    - Rotated Box
    - Trapezoid
    - Triangle
    - Rhombus
    - Parallelogram
    - more coming soon...
- UV
    - UV PolarCoord (CanvasItem and Spatial ShaderMode supported)
    - UV Twirl
    - UV Flipbook
- Utility
    - Random Range
    - Remap
    - Scene Depth
- Wave (click on the links for more detail about the patterns)
    - [Triangle](https://en.wikipedia.org/wiki/Triangle_wave)
    - [Square](https://en.wikipedia.org/wiki/Square_wave)
    - [Sawtooth](https://en.wikipedia.org/wiki/Sawtooth_wave)
    - [Sine (+ Angular Frequency Input variant)](https://en.wikipedia.org/wiki/Sine_wave)

## How to get started
To integrate the Visual Shader nodes library into your project, copy the VisualShaderExtras folder inside your addons folder. If the addons folder doesn't exist yet, create one. There's no further steps or activation through the project settings necessary.

## Why another Visual Shader add-on?
There are already two major Visual Shader add-on solutions. [ShaderV](https://github.com/arkology/ShaderV) is mainly focused on CanvasItem shaders though and [Godot-Visual-Shader-Node-Library](https://github.com/Maujoe/Godot-Visual-Shader-Node-Library) has run stale.

Furthermore, I have plans to work on another add-on (or perhaps a GDExtension) that will utilize the signed distance shapes Shaders for User Interface Design which would make more custom interfaces possible. This idea is heavily inspired by the awesome Unity asset [Shapes by Freya Holmér](https://acegikmo.com/shapes/).

## ℹ️ Contributing
You can contribute by:

* giving feedback
* reporting issues
* creating PRs to solve standing issues
* adding more nodes that you find useful yourself in a PR
* using the library and spreading the word 📰

## 🔢 Versioning
This branch is for the 3.x version of Godot. If you do want to use this addon for 4.0, switch to the 4.0 branch. Beware of breaking changes and bugs in the 4.0 version.
