
## Documentation

[Board documentation](https://doc-en.rvspace.org/VisionFive2/PDF/VisionFive2_QSG.pdf)

## Build an image with Miralis for the VisionFive 2

Use `mkikage` package ([documentation](https://linux.die.net/man/1/mkimage)).

1. You need a .its file that describe the structure of the final image, an image of miralis and whatever firmware or binary you want inside. 

The .its file (image source file) should be updated to add the different binaries and their load address.

Example of the image source file:
``` json
/dts-v1/;

/ {
        description = "U-boot-spl FIT image for JH7110 VisionFive2";
        #address-cells = <2>;

        images {
                firmware {
                        description = "miralis";
                        data = /incbin/("./target/riscv-unknown-miralis/debug/miralis.img");
                        type = "firmware";
                        os = "u-boot";
                        load = <0x0 0x43000000>;
                        entry = <0x0 0x43000000>;
                        compression = "none";
                };

                virtual-firmware {
                        description = "virtual firmware";
                        data = /incbin/("./target/riscv-unknown-firmware/debug/csr_write.img");
                        type = "firmware";
                        arch = "riscv";
                        load = <0x0 0x40000000>;
                        compression = "none";
                }; 
        };

    configurations {
        default = "config-1";

        config-1 {
            description = "U-boot-spl FIT config for JH7110 VisionFive2";
            firmware = "firmware";
            loadables = "virtual-firmware";
        };
    };
};
```

2. The command to build the image is: 

`mkimage -f visionfive2-fit-image.its -A riscv -O u-boot -T firmware vision.img`

## Justfile suggestion

A rule that could be useful for the justfile of Miralis is this one.
We could adapt it to choose the firmware, but the .its file should be updated in consequences.


``` makefile
vision-img:
	cargo run --package runner -- build --config config/visionfive2.toml
	cargo run --package runner -- build -v --config config/visionfive2.toml --firmware csr_write
	mkimage -f visionfive2-fit-image.its -A riscv -O u-boot -T firmware vision.img
```


## Flashing the board with the image.

For small firmware or payload, the easiest way is to use the recovering bootloader technique throught uart explained in the section 4.3 of the [board documentation]((https://doc-en.rvspace.org/VisionFive2/PDF/VisionFive2_QSG.pdf)) and use our image instead of the `visionfive2_fw_payload.img`. You need the board to boot on uart mode.

You can also skip step 6 (unless you corrupted u-boot). You only need to use the function **2**.
> 2: update fw_verif/uboot in flash

To boot after flashing, set the RGPIO pins of the board to flash mode and reset the board.


