# cGithub [![AutoHotkey2](https://img.shields.io/badge/Language-AutoHotkey2-red.svg)](https://autohotkey.com/)

This library uses [AutoHotkey Version 2](https://autohotkey.com/v2/). (Tested with [v2.0-a103-56441b52 x64 Unicode](https://www.autohotkey.com/boards/viewtopic.php?f=37&t=2120&start=40#p276644) or later) 


## Description

AHK class **cGithub** for working with [Github](https://github.com/) from AHK. It's an implementation of [Github Rest-API v3](https://developer.github.com/v3/)

For more documentation see [Github Rest-API v3](https://developer.github.com/v3/) and the class itself

## Usage 

Include `cGithub.ahk`from the `lib` folder into your project using standard AutoHotkey-include methods.

```autohotkey
#include <cGithub.ahk>
gh := new github("hoppfrosch", "hoppfrosch@gmx.de", "***YOUR_ACCESS_TOKEN***")
x := gh.releases.listReleasesForRepository("Autohotkey-V2", "log4ahk")   ; get the JSON-Response from Github
obj := JSON.Load(x)    ; Convert the JSON-String into AHK-object
```

For usage examples have a look at the UnitTest-files in `t` folder and the Demo-Files in the `demos` folder

## Author

[hoppfrosch@gmx.de](mailto:hoppfrosch@gmx.de)
