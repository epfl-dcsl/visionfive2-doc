miralis:
	git clone https://github.com/CharlyCst/miralis
	cd miralis && just build config/visionfive2-release.toml

miralis-protect-payload:
	git clone https://github.com/CharlyCst/miralis
	cd miralis && just build config/visionfive2-release-protect-payload.toml

unmodified-image: miralis
	mkimage -f visionfive-image.its -A riscv -O u-boot -T firmware vision.img

image: miralis
	mkimage -f miralis-image.its -A riscv -O u-boot -T firmware vision.img

protect-payload: miralis-protect-payload
	mkimage -f miralis-image.its -A riscv -O u-boot -T firmware vision.img
