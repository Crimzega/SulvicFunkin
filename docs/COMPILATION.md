# Compiling Funkin Sulvic Engine

## Requirements

### Setup
You'll need to install [Haxe](https://haxe.org/download/)

### Libraries
Run `haxe\libs` in a terminal at the repository's directory
> This is a shorthand way of installing the required libraries.

### Git Repo Handling
You'll also need to install a couple of things that involve git repos.
The following choices are great for handling repos:

- [GitHub Desktop](https://desktop.github.com/) (Windows only)
- [GitAhead](https://gitahead.github.io/gitahead.com/) (Windows, Max, & Linux)
- [Gittyup](https://github.com/Murmele/Gittyup/releases) (Windows, Max, & Linux)
- [Git-SCM](https://git-scm.com/downloads) (For more advanced users)

> There are `orig` files in the `haxe` directory if you would rather have the original repository instead
>
> **Notice**: I recommend running the files the the `haxe` directory than in a terminal in the main folder.

### Compiling on Windows
There is an additional step required for this option.
You would need to download the [Visual Studio Build Tools](https://aka.ms/vs/17/release/vs_BuildTools.exe).

Then you would need to find and select the following from "Individual Components" tab:
- MSVC v143 VS 2022 C++ x64/x86 build tools
- Windows 10 & 11 SDKs
