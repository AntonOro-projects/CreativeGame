# Bawlder Dashers

Be the last Bawlder standing!  

## Angelscript version

This project uses the 5.4.2 version of Unreal Engine/AngelScript.

## Setup Guide

The following sections details how to set up your environment for working on Bawlder Dashers.

On Windows, Visual Studio is used to build and run the custom Unreal Engine version that includes AngelScript. Development of features is then made in another text editor, such as Visual Studio Code.

### Access to Unreal Engine source code

In order to be able to work on the project, you will first need to make sure your Github account has access to the Unreal Engine source code in Github.
You can follow these steps found in their own documentation to do so [here](https://www.unrealengine.com/en-US/ue-on-github)

### Clone this Repository

Clone this repository, and to avoid long pathnames, put it close to the path root as possible, for example at `C:\Repos\`.

### Install AngelScript (Windows)

AngelScript has documentation of their own found [here](https://angelscript.hazelight.se/), but in short what you need to do is the following:

1. Download the 11 archives found under 5.4.2 [here](https://github.com/Hazelight/UnrealEngine-Angelscript/releases) (the ones named UnrealEngine-Angelscript-5.4.2.7z.001-UnrealEngine-Angelscript-5.4.2.7z.011)
2. Create a new folder directly under C: named AngelScript.
3. Mark all 11 downloaded archives (highly likely ended up in your Downloaded folder) and use a decompression tool like 7Zip (can be downloaded [here](https://7-zip.org/a/7z2408-x64.exe)) and choose to **Extract files** and choose the location (AngelScript folder that you created in the previous step.)
4. Verify the installation by going to AngelScript > UnrealEngine-Angelscript-5.4.2 > Engine > Binaries > Win64 > UnrealEditor - this should open Unreal Engine's Editor.

### Install Visual Studio 2022 (17.12)

Install the Long-Term Servicing Channel version of Visual Studio 2022, 17.12, available [here](https://learn.microsoft.com/en-us/visualstudio/releases/2022/release-history). Newer versions will not compile Unreal Engine and the game, so make sure to install the correct one. During installation, or afterwards by modifying the installation with Visual Studio Installer, add the following things:

* Workloads
  * .NET desktop development
  * Desktop development with C++
  * Game development with C++

### Preparing the Editor

In the cloned repository, right-click the `BawlderDashers.uproject` file, and select the option Generate Visual Studio project files (if not visible, try Show more options or shift right-clicking the file). This will create a BawlderDashers solution file in the root of the repo.

### Starting the Editor

Open the solution file with Visual Studio 2022 17.12, and select BawlderDashers as the Startup Project (Solution Explorer: Games/BawlderDashers, right click, Set as Startup Project). Then click Start without Debugging and after finishing building, the editor should open.

### Install Visual Studio Code

Install visual studio code [here](https://code.visualstudio.com/).

Then install the Unreal Angelscript Extension from the marketplace, or search for 'Unreal Angelscript' in the extensions sidebar within Visual Studio Code.

### Unreal AngelScript Clang-Format

This extension for VS Code can be used for formatting AngelScript code.
Simply download it [here](https://marketplace.visualstudio.com/items?itemName=Hazelight.unreal-angelscript-clang-format).
Make sure to have the latest version of Clang-format installed, you can download it [here](https://github.com/llvm/llvm-project/releases/tag/llvmorg-18.1.8)(18.1.8).

## Development Guide

Bawlder Dashers uses GitHub Projects to manage ongoing work. You can find the project used [here](https://github.com/orgs/DashyStudios/projects/5).

### PRs

Please include some reasoning behind your work, and why it is needed. Adding the task in GitHub Projects (by adding `Fixes #<issue number>` to the description) is a good way to do this.

Also include some video footage/screenshot of your work when applicable.

After merging a PR, please make sure the branch of your work is properly deleted afterwards.

## FAQ

### I got some time over and want to help out, where can I find tasks to work on?

You can enter the [Github Project](https://github.com/orgs/DashyStudios/projects/5) for this repo, here you can find tasks that are split up in different categories and statuses.
We currently do not have a Design document to base implementations of, instead we rely on talking to eachother and our own creativity to make this project the best we can

### Is the BawlderMovementComponent.as supposed to wake the rigidbodies every frame?

Yes, because the person writing this could not find a better solution, problem being that the actors, even when told not to go to sleep, still go to sleep. 
This removes them from the physics engine almost completely until a continous force is added or the actor is forced to wake in the manner it is now.
If you, person reading this, has a better solution please implement it as it was driving the person writing this nuts.

**Will be updated as project progresses.**
