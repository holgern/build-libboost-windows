Batch script to download and build libboost (using Visual Studio compiler)

```
Please keep in mind compiling Boost library takes a very long time.
```

**Usage**:

1. Clone or download this repo https://github.com/blackrosezy/build-libboost-windows/archive/master.zip

2. Open command prompt and cd to `xxx/build-libboost-windows`

3. Run this command for building static and shared library:
```
build.bat 32 msvc
```
or for 64 bit
```
build.bat 32 msvc
```
Run this command for building  shared library:
```
build_dll.bat 32 msvc
```
or for 64 bit
```
build_dll.bat 64 msvc
```
Run this command for building  static library:
```
build_lib.bat 32 msvc
```
or for 64 bit
```
build_lib.bat 64 msvc
```

**Third-party**:

This program is using third party tools:

http://sourceforge.net/projects/unxutils/files/unxutils/current/

http://www.7-zip.org/download.html

http://sourceforge.net/projects/videlibri/files/Xidel/
