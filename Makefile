all:release


flash_chipbot:prepare_rootfs
	@echo "[ Flash CHIP_bot ]"
#TODO

flash_pocketchip:prepare_rootfs
	@echo "[ Flash PocketCHIP ]"
#TODO

prepare_rootfs:release
	@echo "[ Prepare Rootfs.tar archive with release folder ]"
	@sudo ./scripts/prepare_rootfs.sh -i release/rootfs.tar -o release/prepared_rootfs.tar -f release/

release:linux buildroot uboot src
	@echo "[ Generate release ]"
	@rm -rf release/ && mkdir release/
	@cp linux/arch/arm/boot/zImage                      release/
	@mkdir release/linux_modules/
	@cp -r linux/target/lib/                            release/linux_modules/
	@cp linux/arch/arm/boot/dts/sun5i-r8-chip.dtb       release/
	@cp linux/arch/arm/boot/dts/sun5i-r8-pocketchip.dtb release/
	@cp buildroot/output/images/rootfs.tar              release/
	@cp uboot/spl/sunxi-spl.bin                         release/
	@cp uboot/u-boot-sunxi-with-spl.bin                 release/
	@cp uboot/u-boot.bin                                release/
	@cp uboot/u-boot-sunxi-padded.bin                   release/
	@cp src/chip_bot                                    release/

linux:
	@echo "[ Build GNU/Linux kernel ]"
	@cp configs/linux.conf linux/.config
	@cd linux && rm -rf target/ && mkdir target/
	@cd linux && ./make_linux.sh
	@echo "[ Install GNU/Linux kernel modules ]"
	@cd linux && ./make_linux.sh modules_install install

buildroot:
	@echo "[ Build Buildroot ]"
	@cp configs/buildroot.conf buildroot/.config
	@cd buildroot/ && $(MAKE)

uboot:
	@echo "[ Build UBoot bootloader ]"
	@cp configs/uboot.conf uboot/.config
	@cd uboot && ./make_uboot.sh

src:buildroot
	@echo "[ Build Source ]"
	@cd src/ && ./make_target.sh

distclean:
	@echo "[ Distclean all project ]"
	@cd linux/ && $(MAKE) distclean
	@cd buildroot/ && $(MAKE) distclean
	@cd uboot/ && $(MAKE) distclean
	@cd libcommon/ && $(MAKE) distclean
	@cd src/ && $(MAKE) distclean
	@rm -rf release/

clean:
	@echo "[ Clean all project ]"
	@cd linux/ && $(MAKE) clean
	@cd buildroot/ && $(MAKE) clean
	@cd uboot/ && $(MAKE) clean
	@cd libcommon/ && $(MAKE) clean
	@cd src/ && $(MAKE) clean

.PHONY:                \
all                    \
src                    \
linux                  \
buildroot              \
uboot                  \
distclean              \
clean
