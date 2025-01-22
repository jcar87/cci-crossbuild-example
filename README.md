# cci-crossbuild-example
Example to crossbuild Conan Center recipes with system dependencies on Ubuntu

Note: assuming Docker is running on `x86_64`

### Build docker image
```
git clone https://github.com/jcar87/cci-crossbuild-example.git
cd cci-crossbuild-example
docker build . -t cci-crossbuild-example
```

### Build conan recipes inside docker image
Example only

Drop into a shell inside the image:
```
docker run --rm -ti cci-crossbuild-example /bin/bash
```

Issue a `conan install` command for `opencv/4.10.0` - allow Conan to build missing dependencies.

```
conan install --require=opencv/4.10.0 --envs-generation=false --build=missing --profile arm64 --conf:all tools.system.package_manager:mode=install
```

### Notes:
Ubuntu is multiarch (read [more](https://wiki.debian.org/Multiarch/HOWTO)) - this way we are able to resolve "system" dependencies while keeping the sysroot at `/`

This is achieved by:
- Enabling the `arm64` architecture in dpkg with `dpkg --add-architecture`
- Amending the `apt` sources such that they point to the correct archives for each architecture
- Using the crossbuild toolchain provided by the `crossbuild-essential-arm64`
- Using `pkg-config` tailored for the crossbuild environment, by installing the `pkgconf:arm64` package.
    - This can be confirmed with `aarch64-linux-gnu-pkgconf --dump-personality` 
- Reflecting the above in a Conan profile:
   - `arch=armv8`
   - Compiler executables are:
      - `aarch64-linux-gnu-gcc` for the C compiler
      - `aarch64-linux-gnu-g++` for the C++ compiler
   - The `tools.gnu:pkg_config` conf
       - Point to `/usr/bin/aarch64-linux-gnu-pkgconf`, this allows it to find the system dependencies for the "host" architecture
