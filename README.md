# flakes

This contains flakes for the MBF anysnake2/NIXos system.
The goal is to provide neccessary binaries for external tools.

## Use the flakes:

Copy into anysnake2.toml:

```
[flakes.gdc]
	url = "github:MarcoMernberger/flakes?dir=gdc" 
	rev = "31b36d177af7339099b0b9eb042e2adaa0934a5d" # from this repo
	# follows = ["nixpkgs"] # do follow, so no infinite nixpkgs
	packages = ["defaultPackage.x86_64-linux"]

[flakes.GATK]
	url = "github:MarcoMernberger/flakes?dir=GATK" 
	rev = "ab1b3acb9c0a71a526d7b3b6f2a74ebdd9975831" # from this repo
	# follows = ["nixpkgs"] # do follow, so no infinite nixpkgs
	packages = ["defaultPackage.x86_64-linux"]

[flakes.varscan2]
	url = "github:MarcoMernberger/flakes?dir=varscan2" 
	rev = "ab1b3acb9c0a71a526d7b3b6f2a74ebdd9975831" # from this repo
	# follows = ["nixpkgs"] # do follow, so no infinite nixpkgs
	packages = ["defaultPackage.x86_64-linux"]

```
