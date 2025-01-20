# How to run a keystone enclave
## Short Version
### Running using Miralis
cd into the Miralis repository and do the following
```bash
# Launch Miralis with OpenSBI and a linux image
just run keystone ./config/qemu-keystone.toml

# At this point, you should be in the qemu-emulated environment
# Load the keystone driver
modprobe keystone-driver

# To try to run an enclave, head to the examples directory
cd /usr/share/keystone/examples

# There, you can run the examples
./hello.ke
```

### Running without Miralis
cd into the Keystone repository (which you might need to clone recursively) and do the following
```bash
# Build all the components
make

# Run the linux image and login as `root` with the password `sifive`
make run

# At this point, you should be in the qemu-emulated environment
# Load the keystone driver
modprobe keystone-driver

# To try to run an enclave, head to the examples directory
cd /usr/share/keystone/examples

# There, you can run the examples
./hello.ke
```

## Long Version
### Build Process
The following components are built in the [miralis-artifact-keystone](https://github.com/FredKhayat/miralis-artifact-keystone) repository to create the Linux and Disk images:
+ musl-cross-make: This repository is used to build `riscv64-linux-musl-gcc`, a cross-compiler that links against musl libc (A specific implementation of libc).
+ keystone-iozone: This repository is used to build a Keystone compatible version of the iozone benchmark. It uses `riscv64-linux-musl-gcc` to statically build the binary.
+ keystone: This repository is used to build the keystone drivers, runtimes, Eapps, the linux image, and the disk image.
+ opensbi: This repository is used to build an OpenSBI executable that will jump to the linux image (FW_PAYLOAD=y).

### Keystone patches
The `keystone.patch` file in the [miralis-artifact-keystone](https://github.com/FredKhayat/miralis-artifact-keystone) repository contains the following changes to keystone:
+ Removed the linux password and set the init program to bash
+ Removed the test `test-fib-bench` as it executes the instruction `rdcycle` which causes problems with Miralis
+ Created a host application for iozone. (At `examples/iozone/host/host.cpp`)
+ Created a CMakeLists.txt that can copy the iozone binary to the enclave package (At `examples/iozone/CMakeLists.txt`)

### Running an Enclave
Enclaves are packaged as .ke files. To run an enclave it is sufficient to run the .ke file (`./enclave.ke`).

A .ke file is simply a [makeself](https://github.com/megastep/makeself) file. That's a self-extracting binary that runs the enclave automatically. It is possible to use `--help` to see the available options. In particular, the interesting options are:
+ `--noexec`: Do not execute the binary.
+ `--target dir`: Un-package the .ke file into `dir`

If you try to un-package a .ke file, you will see that it will contain something similar to this:
```bash
bash-5.2# ./hello.ke --noexec --target hello
bash-5.2# ls -lh hello
# -rwxr-xr-x    1 1001     118       157.0k jan 16  2025 eyrie-rt
# -rwxr-xr-x    1 1001     118       648.0k jan 16  2025 hello
# -rwxr-xr-x    1 1001     118       341.8k jan 16  2025 hello-runner
# -rwxr-xr-x    1 1001     118        44.0k jan 16  2025 loader.bin
```
Above, you can see the runtime, the enclave binary, the enclave runner (the host) and a file called `loader.bin` used by the runner.
In order to run the enclave using those components separately, you can execute a command similar to this one:
```bash
./hello-runner hello eyrie-rt loader.bin
```

Note that some runners (in particular, the tests and the iozone runners) can take additional arguments (use --help to see them) that can be very useful to specify the size of the enclave memory and the size of the untrusted shared buffer. 

Common errors:
+ `[warn] eyrie simple page allocator cannot evict and free pages (freemem.c:37)`: It probably indicates that the enclave was not given enough memory and can be fixed by increasing enclave memory using the `--freemem-size` option of the runner.
+ Segmentation fault: it is possible that QEMU was not given enough memory (which can be fixed using the `-m` QEMU option)

### Running on the board
The board uses U-Boot to load linux. It's possible to interrupt the automatic boot process by hitting any key during boot. Once inside the U-Boot command prompt, you can use `help` to list all the available commands, but the most useful ones are:
+ `printenv`: Prints the U-Boot environment variables. In particular, the `bootcmd` variable contains the command that is executed automatically if the boot process is not interrupted
+ `setenv`: To set or change an environment variable
+ `run`: To run a command in an environment variable

If you carefully analyze the default boot process, you will see that U-boot will end up loading the components specified in a configuration file. The configuration file is in a directory under `/boot` (I forgot the exact names of the config directory and file). Normally, by simply editing this file, you should be able to modify the boot process (which can be useful to load a different version of linux).

### iozone
When running iozone from an enclave, you might get I/O errors. I'm not sure why but this might be because the disk image is full or because the enclave was not given enough memory.
The following repo might give some hints on how to solve that problem: https://github.com/keystone-enclave/keystone-bench
