generate-visionfive2-image:
	sudo apt update
	sudo apt upgrade
	sudo apt install gcc-riscv64-linux-gnu
	git clone https://github.com/starfive-tech/u-boot.git
	cd u-boot
	git checkout -b JH7110_VisionFive2_devel origin/JH7110_VisionFive2_devel
	git pull
	make starfive_visionfive2_defconfig ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu-
	make ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu-
	cd ..
	


unmodified-image: 
	git clone https://github.com/CharlyCst/miralis
	cd miralis && just build config/visionfive2.toml && cd ..
	mkimage -f visionfive-image.its -A riscv -O u-boot -T firmware vision.img

image: 
	cd ../miralis && just build config/visionfive2-release.toml && cd ..
	mkimage -f miralis-image.its -A riscv -O u-boot -T firmware vision.img
	cp vision.img ../

image-per-code: 
	git clone https://github.com/CharlyCst/miralis
	cd miralis && git checkout fine-grained-counter-benchmark && just build config/visionfive2-release-traps.toml && cd ..
	mkimage -f miralis-image.its -A riscv -O u-boot -T firmware vision-per-code.img
	cp vision-per-code.img ../

offload: 
	cd ../miralis && just build config/visionfive2-release-offload.toml && cd ..
	mkimage -f miralis-image.its -A riscv -O u-boot -T firmware vision.img
	cp vision.img ../

keystone:
	cd ../miralis && just build config/visionfive2-keystone.toml && cd ..
	mkimage -f miralis-image.its -A riscv -O u-boot -T firmware vision.img
	cp vision.img ../

protect-payload: 
	cd ../miralis && just build config/visionfive2-release-protect-payload.toml && cd ..
	mkimage -f miralis-image.its -A riscv -O u-boot -T firmware vision.img
	cp vision.img ../

tracing: 
	cd ../miralis && just build config/visionfive2-release.toml && 	just build-firmware tracing_firmware ./config/visionfive2.toml && cd ..
	mkimage -f visionfive-image-tracing.its -A riscv -O u-boot -T firmware vision-tracing.img
	cp vision-tracing.img ../
