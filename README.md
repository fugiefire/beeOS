# beeOS
literally just prints the bee movie script, nothing else

beeOS is opensourced and is licensed as do whatever you want with it.

To run beeOS, you can either compile from source, or download from the releases page.
## Building
### Dependencies
```
Some cross compiler toolchain, including gcc and ld
nasm
qemu
```

I've only tested compilation on macOS, I don't know how it will behave on linux. You will need a cross compiler toolchain, in my case the prefix is `x86_64-elf-` for the tools. This is defined in the Makefile on line 9, `KERN_TOOL_PREFIX`. To do a clean build of it, simply:
```
$ make cbuild
```
This will output 3 `.bin`'s in the top level directory: `kernel.bin`, `boot.bin`, and, most importantly, `beeOS.bin`. Neither `kernel.bin` or `boot.bin` should be run standalone. 

## Running beeOS
To run beeOS, you can either:
```
make run
```
Or:
```
qemu-system-x86_64 -hda beeOS.bin
```
