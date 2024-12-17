miralis:
	git clone https://github.com/CharlyCst/miralis
	cd miralis && just build config/visionfive2.toml
	cp 

unmodified-image: miralis
	mkimage -f visionfive-image.its -A riscv -O u-boot -T firmware vision.img

image: miralis
	mkimage -f miralis-image.its -A riscv -O u-boot -T firmware vision.img
