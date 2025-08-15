# Anton's Creative Game Brainchild

A creative sandbox game where players get full systemic control to spawn meshes, group them, attach/detach capabilities, toggle activation and ticking, and wire behaviors together to create contraptions, mini-games, and worlds!

## Setup Guide (Windows)

The following sections details how to set up your environment to contribute to the project.

On Windows, Visual Studio is used to build and run the custom Unreal Engine version that includes AngelScript. Development of features is then made in another text editor, such as Visual Studio Code.

### Clone This Repository

Clone this repository, and to avoid long pathnames, put it close to the path root as possible, for example at `C:\Repos\`.

### Install Visual Studio Code

This game uses the latest version of VS Code (as of 2025.08). 
1. Download the latest version for Windows and follow the instructions [here](https://code.visualstudio.com/docs/setup/windows).
2. Install the Unreal Angelscript Extension to help with auto-completion and debugging, search for "Unreal Angelscript" in the extensions sidebar within Visual Studio Code.

### Install Unreal Engine with AngelScript (Windows)

This project uses the latest version of Unreal Engine/AngelScript, as of 2025.08.

Hazelight has documentation of their own found [here](https://angelscript.hazelight.se/getting-started/installation/), but in short you need to do the following:
1. Get access to Unreal Engine source code, following [this guide](https://www.unrealengine.com/en-US/ue-on-github).
2. Download UnrealEngine-Angelscript by cloning the [UnrealEngine-Angelscript GitHub Repository](https://github.com/Hazelight/UnrealEngine-Angelscript).
3. Build the engine from source using the instructions [here](https://dev.epicgames.com/documentation/en-us/unreal-engine/building-unreal-engine-from-source).

### (Optional) Unreal AngelScript Clang-Format

This extension for VS Code can be used for formatting AngelScript code.

Simply download it [here](https://marketplace.visualstudio.com/items?itemName=Hazelight.unreal-angelscript-clang-format).

Make sure to have the latest version of Clang-format installed, you can download it [here](https://github.com/llvm/llvm-project/releases).

### Preparing The Editor

In the cloned repository, right-click the CreativeGame.uproject file, and select the option Generate Visual Studio project files (if not visible, try Show more options or shift right-clicking the file). This will create a CreativeGame solution file in the root of the repo.

### Starting The Editor

Open the solution file with Visual Studio, and select Creative Game as the Startup Project (Solution Explorer: Games/CreativeGame, right click, Set as Startup Project). Then click Start without Debugging and after finishing building, the editor should open.

## Setup Guide for Mac
3. Get access to Unreal Engine source code, following [this guide](https://www.unrealengine.com/en-US/ue-on-github).
2. Download UnrealEngine-Angelscript by cloning the [UnrealEngine-Angelscript GitHub Repository](https://github.com/Hazelight/UnrealEngine-Angelscript).
4. Download and install the latest version of XCode [here](https://developer.apple.com/xcode/) 
5. In the repo folder, open terminal:
    1. Paste command:
        ```
        cd /[path to folder]
        ./Setup.command       
        ./GenerateProjectFiles.command
        ```
    3. This will generate the necessary project files
6. Open the generated `.xcworkspace` in Xcode
7. First, build the **ShaderCompileWorker for My Mac** target, then the **UE5Editor** target (or similar), via Product > Build
8. This will compile the engine and launch the editor

## Development Guide

You can find the Technical Design Document for the project [here](https://www.notion.so/Creative-Engine-Game-Technical-Design-Document-24c64336aa0680e680a0c6e7712350f0) on Notion.

We use GitHub Projects to manage ongoing work. You can find the project used [here](https://github.com/orgs/DashyStudios/projects/8).

### PRs

Please include reasoning behind your work, and why it is needed. Adding the task in GitHub Projects (by adding `Fixes #<issue number>` to the description) is a good way to do this.

Also include some video footage/screenshot of your work when applicable.

After merging a PR, please make sure the branch of your work is properly deleted afterwards.

## FAQ


**This will be updated as project progresses.**
