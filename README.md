# Chicken build_static.sh

Build a static binary for a [Chicken Scheme](https://call-cc.org) program inside a docker image and return it.

## Dependencies

This script only depends on docker and bash. You need to have the docker daemon
running. You will also need a working network to be able to pull the [base image](https://hub.docker.com/repository/docker/lattay/chicken)
from dockerhub, unless you proceed to get the image by another mean.
For Windows build the base image is [here](https://hub.docker.com/repository/docker/lattay/chicken-mingw).

## Usage
Copy the *build_static.sh* file to your project and call it with the right
options. The *sample* directory contains a basic example of how it is used with a small
Chicken program and a Makefile.

```
Usage: build_static.sh OPTIONS... ENTRYPOINT [-- COMPILER_OPTIONS...]
Options:
-g, --egg EGG            Add an egg to installed before building the binary
-s, --source SRC_FILE    A source file to copy
-a, --arch ARCH          Target architecture name (amd64 or armv7)
-p, --platform PLATFORM  Target platform name (linux or mingw)
-v, --version VERSION    Chicken version (5.2)
-b, --bin-name BIN_NAME  How the final binary should be called
-k, --keep               Do not overwrite the Dockerfile if it already exists
--static                 Build a fully static binary
ENTRYPOINT               Filename of the binary entrypoint
COMPILER_OPTIONS         Options to be directly passed to chicken compiler
```

## Support

Supported platform are currently Linux on AMD64, Linux on ARMv7 and MingGW (Win32) on AMD64.
If you are interested in a different platform please submit an [issue](https://github.com/Lattay/chicken-build-static/issues) as it may need cross compilation.

Supported Chicken version is currently restricted to Chicken 5.2.0 but it should be fairly easy to support other version using an appropriately modified version of the [base image Dockerfile](https://github.com/Lattay/chicken_docker).
