# Yocto Project - Raspberry Pi Zero 2 W Build

A custom embedded Linux distribution built with Yocto Project for Raspberry Pi Zero 2 W, featuring custom machine configuration, kernel optimizations, device tree overlays, and kernel modules.

Big thanks to **Techleef** that gives me this opportunity.

#### Disclaimer: This repository serves as both a functional Yocto project and comprehensive documentation of my learning journey. The content includes detailed notes and troubleshooting steps.

Let's say it's Yocto/Embedded Linux Hacking ^_^.

## Overview

This repository contains my first Yocto project implementation, documenting the complete process of development. The project uses KAS for build automation , Docker for containerized development environment and **No Poky**.

## Hardware Requirements

- Raspberry Pi Zero 2 W
- MicroSD card (16GB)
- FT232RL

## Project Architecture

### Main Directories
- **openembedded-core / bitbake / meta-raspberrypi**: under meta/layers
- **Custom layer**: meta-aero-bsp
- **KAS yml file**: for automatic configuration and building instead of sourcing oe script
- **Container image files and directories**: checking setup
- **HTTP server**: host /images via docker, accessible in local network and shared between team

## Setup Process

### 1. Prepare KAS yml Files
- KAS yml files for all layers and local configuration
- Commands:
  - Build: `kas-container build kas-prj.yml`
  - Execute bitbake command: `kas-container shell kas-prj.yml`
- Successfully generated first image with default raspberrypi2w config

### 2. Docker Setup
- **Manual approach**: 
  - Host directory using `docker run -it`
  - Add `-v` for file sharing between container and local machine
- **KAS-container approach**: using kas-container instead of kas + manual docker configuration

### 3. Custom Downloads and State Cache
- Use `local_conf_header` in kas file to define custom paths for SSTATE and DL_DIR

### 4. Build Information Output
- Add to local_conf_header:
  ```
  INHERIT += "buildhistory"
  BUILDHISTORY_COMMIT = "1"
  ```

### 5. Docker HTTP Server Script
- Developed script to setup docker HTTP server over packages deploy directory
  <img width="1147" height="407" alt="image" src="https://github.com/user-attachments/assets/c4d9bbb9-5669-40e1-a714-61ebd7b6cc48" />


## Custom Machine Development

### 1. Creating Custom Layer (meta-aero-bsp)
- Added new machine called `aero-RPI`

### 2. Booting the image

### Flashing and Serial Connection
```bash
bunzip2 -f core-image-minimal-aero-rsp.rootfs.wic.bz2
sudo dd if=core-image-minimal-aero-rsp.rootfs.wic of=/dev/mmcblk0 bs=1M status=progress conv=fsync
```

- **Serial connection**: `picocom /dev/mmcblk0 -b 115200`
  - Issue with picocom input login, switched to `screen` instead
- **UART setup**: Add `ENABLE_UART = "1"` in kas file for FTDI usage
- **Alternative flashing**: Balena Etcher proved easier and safer than dd

### 3. Machine Feature Control

### Check current features:
```bash
bitbake -e | grep '^MACHINE_FEATURES='
```
Result: `MACHINE_FEATURES=" apm usbhost keyboard vfat ext2 screen touchscreen alsa bluetooth wifi sdio vc4graphics qemu-usermode"`

### Remove unwanted features:
```
MACHINE_FEATURES:remove = 'apm usbhost keyboard screen touchscreen alsa bluetooth sdio vc4graphics qemu-usermode'
```
Result: `MACHINE_FEATURES="    vfat ext2     wifi"`

### 4. Kernel Optimization

### Remove Kernel from Rootfs
- Attempted: `IMAGE_INSTALL:remove = "kernel-image kernel-devicetree kernel-base kernel-modules"`
- **Status**: Not working - raspberrypi2w config automatically adds kernel to rootfs
- **Note**: Need more investigation

### Menuconfig Optimizations
- Auxiliary display support: [n]
- Changed default hostname
- Enabled optimize for size
- Disabled sound support

**Results**:
- Old kernel image: 7.3M kernel7.img
- New kernel image: 4.4M kernel7.img

### Configuration verification:
```bash
diff ./linux-raspberrypi/6.6.63+git/sources-unpack/defconfig ./linux-raspberrypi/6.6.63+git/linux-aero_rsp-standard-build/defconfig
grep SOUND .config  # Result: # CONFIG_SOUND is not set
```

### 5. Device Tree Overlay

### LED Overlay Recipe
- Added `led.dts` file under files directory
- Used `do_configure:append()` to copy `my-led-overlay.dts` into overlays dts and add to MAKEFILE
- Verified overlay location: `./build/tmp/work-shared/aero-rsp/kernel-source/arch/arm/boot/dts/overlays/myled-overlay.dts`

### Configuration:
```
KERNEL_DEVICETREE:append = " overlays/myled.dtbo"
RPI_EXTRA_CONFIG = "dtoverlay=myled"
```

### Testing:
- Successfully controlled LED: `echo 1 > /sys/class/leds/simple_led/brightness`
<div align="center">
  <img src="https://github.com/user-attachments/assets/0c15491c-a93c-4326-9d65-11cac9fbcb21" height="400">
</div>


### 6. Kernel Module Recipe

### Setup:
- Created `my_module` directory structure
- Added `my-module.bb` recipe
- Created `files` subdirectory with `hello.c` and `Makefile`
- Added to configuration: `IMAGE_INSTALL:append = " my-module"`

### Verification:
```bash
ls /tmp/wic_rootfs/lib/modules/6.6.63-v7/updates/
# Result: hello.ko.xz
```
- Now let's test out module, in this case our module is a considered as standard kernel module , so i m using modprobe instead of insmod.
- <img width="937" height="378" alt="image(1)" src="https://github.com/user-attachments/assets/fe7ad185-88cf-4b0a-8783-50bb0c122125" />

### 7. Boot time optimization

### Very minimal kernel defconfig
- Very minimal kernel defconfig (already did, maybe adding more stuff) I found that I missed this one CONFIG_USB_SUPPORT.

### Disable as much bootloader configs as possible
- First reading the boot process messages, and I found that the boot is 8 seconds (that's too much)
```
[    0.200167] calling  deferred_probe_initcall+0x0/0x9c @ 1
[    0.205851] probe of 3f101000.cprman returned 0 after 5512 usecs
[    0.206178] uart-pl011 3f201000.serial: cts_event_workaround enabled
[    0.206382] probe of 3f201000.serial:0 returned 0 after 30 usecs
[    0.206485] probe of 3f201000.serial:0.0 returned 0 after 28 usecs
[    0.206512] 3f201000.serial: ttyAMA1 at MMIO 0x3f201000 (irq = 114, base_baud = 0) is a PL011 rev2
[    0.206746] serial serial0: tty port ttyAMA1 registered
[    0.206835] probe of 3f201000.serial returned 0 after 945 usecs
[    0.207494] probe of 3f215000.aux returned 0 after 588 usecs
[    0.207569] bcm2835-aux-uart 3f215040.serial: there is not valid maps for state default
[    0.207968] printk: console [ttyS0] disabled
[    0.208276] probe of 3f215040.serial:0 returned 0 after 27 usecs
[    0.208372] probe of 3f215040.serial:0.0 returned 0 after 26 usecs
[    0.208399] 3f215040.serial: ttyS0 at MMIO 0x3f215040 (irq = 86, base_baud = 50000000) is a 16550
[    0.208435] printk: console [ttyS0] enabled
[    7.852532] probe of 3f215040.serial returned 0 after 7644975 usecs
[    7.859468] bcm2835-wdt bcm2835-wdt: Broadcom BCM2835 watchdog timer
[    7.865947] probe of bcm2835-wdt returned 0 after 6750 usecs
[    7.871960] bcm2835-power bcm2835-power: Broadcom BCM2835 power domains driver
[    7.879299] probe of bcm2835-power returned 0 after 7469 usecs
[    7.885261] probe of 3f100000.watchdog returned 0 after 26243 usecs
[    7.892078] probe of 3f212000.thermal returned 0 after 370 usecs
[    7.898704] mmc-bcm2835 3f300000.mmcnr: mmc_debug:0 mmc_debug2:0
[    7.904810] mmc-bcm2835 3f300000.mmcnr: DMA channel allocated
[    7.931793] probe of 3f300000.mmcnr returned 0 after 33522 usecs
[    7.938490] sdhost: log_buf @ 37041243 (d7d43000)
[    7.990895] mmc0: sdhost-bcm2835 loaded - DMA enabled (>1)
[    7.996685] probe of 3f202000.mmc returned 0 after 58719 usecs
[    8.002764] initcall deferred_probe_initcall+0x0/0x9c returned 0 after 7802583 usecs
```
- bcm2835-aux-uart 3f215040.serial: there is not valid maps for state default, I noticed that there is a problem with initialization of serial driver, so I have reset cmdline.txt to default value using "bitbake -c clean rpi-cmdline" and changed from console=serial0 to ttyS0
- Now the boot time is 1.7 seconds
- For now I still don't know how I can change configs to cmdline.txt using my machine config, so I'm editing it manually. I hope I can find a solution ASAP.
- Generated boot time graph with help of bootline documentation you find step and svg in **Doc** dir. 

- Adding these to my machine config:
```
# Disable all unnecessary features
    disable_splash=1
    boot_delay=0
    disable_overscan=1
    # Minimal GPU memory
    gpu_mem=16
    # Disable audio completely
    dtparam=audio=off
    # Disable camera
    start_x=0
    # Disable HDMI
    hdmi_blanking=2
```
- sadly, I couldn't see any difference in boot time for now.
### Use as minimum init manager services as possible

- I couldn't a proper way to remove unecessary services, while im using sysvinit (default init manager), so i should remove manually that services from rootfs , to do that i need to create a recipe, not a package recipe like before but an image recipe, before creating it we need to know the process of image recipes.
  
### Package recipes process:
- do_fetch → do_configure → do_compile → do_install → do_package
### Image recipes process:
- do_rootfs → ROOTFS_POSTPROCESS_COMMAND → do_image
- That's why i created a new recipe called core-image-minimal.bbappend so i can append rootfs process by remove unecessary serices:
```
remove_unwanted_services(){
    rm -f ${IMAGE_ROOTFS}/etc/init.d/networking
    echo "-->removing ${IMAGE_ROOTFS}/rootfs/etc/init.d/networking"
    rm -f ${IMAGE_ROOTFS}/etc/init.d/banner.sh

    rm -f ${IMAGE_ROOTFS}/etc/rc*.d/*networking
    rm -f ${IMAGE_ROOTFS}/etc/rc*.d/*banner
}

ROOTFS_POSTPROCESS_COMMAND:append = " \
  remove_unwanted_services; \
"
```
- clearing core-image-minimal do_rootfs then building again fix it as expected :
```
bitbake core-image-minimal -f -c do_rootfs
bitbake core-image-minimal

ls ./tmp/work/aero_rsp-oe-linux-gnueabi/core-image-minimal/1.0/rootfs/etc/init.d
alignment.sh  checkroot.sh  functions    modutils.sh  populate-volatile.sh  read-only-rootfs-hook.sh  save-rtc.sh  stop-bootlogd  udev          urandom
bootlogd      devpts.sh     halt         mountall.sh  rc                    reboot                    sendsigs     sysfs.sh       umountfs
bootmisc.sh   dmesg.sh      hostname.sh  mountnfs.sh  rcS                   rmnologin.sh              single       syslog         umountnfs.sh

```
- YAY they are really removed.(it may could be another elegant method but this what i got for now).
### Using u-boot instead of GPU directly bootloader:
-Since I’m using a Raspberry Pi, the default bootloader is not U-Boot; it’s the GPU firmware bootloader, which uses these files: start*.elf, bootcode.bin, and kernel*.img. It’s easy to use, easy to configure, and requires no compilation, but it is very specific to the Raspberry Pi. That’s why I’m thinking of switching to U-Boot. Let’s do some U-Boot hacking ^_^.

-PS: It's 2025 not 2024 hehe, we will fix it later.... 
<img width="1527" height="519" alt="image" src="https://github.com/user-attachments/assets/367be217-53aa-45bb-8b9a-5ac1104b62cc" />




### Using u-boot falcon mode:
<img width="1566" height="871" alt="image" src="https://github.com/user-attachments/assets/bb6ad76b-49fa-4f8d-a367-6489aa67282f" />


-Im planning to use falcon mode , but i don't found a good documentation for how to use it, we will get back to it later.

# Custom Distribution

## Separate Yocto Distribution Layer Development
- meta-aero-distro

## Custom Distro Configuration Development

### 1. Support for both init managers (systemd and sysvinit) controlled by a variable
- INIT_MANAGER bitbake variable can be set to systemd or sysvinit. I have tested both, but sysvinit is faster by almost 2 seconds.
- Using **busybox** instead of **core-utils + bash**, because busybox is a single binary about 1-2MB while core-utils + bash almost 14 MB with max of GPL3 and GPL2 , so **busybox** is the king here.
- Let's check that busybox is Added or not : Yes it's valid as the image shows.
<img width="1265" height="904" alt="image(2)" src="https://github.com/user-attachments/assets/0ab3e4fe-2ddb-468c-9797-056d7367ce54" />

### 2. Optimizations (no recommended packages, full control over distro features)
```
DISTRO_FEATURES = "ext2"
# This feature is added by DISTRO_FEATURES_BACKFILL
DISTRO_FEATURES:remove = "pulseaudio"
```

### 3. No Poky
Of course!

### 4. Enable CVE checks
```
# CVE report generated under: build/tmp/deploy/cve
INHERIT += "cve-check"
```
INHERIT is used to include the cve-check bbclass. If we examine the cve-check.bbclass, we can see that it contains "addtask cve_check before do_build".

### 5. Disable GPLv3 packages for all images
```
INCOMPATIBLE_LICENSE:pn-core-image-minimal = "AGPL-3.0-only AGPL-3.0-or-later GPL-3.0-only GPL-3.0-or-later LGPL-3.0-only"
```
This needs to be made specific to our target core-image-minimal; otherwise, the build will fail.

### 6. Enable build information integration for all images
- Adding `INHERIT += "image-buildinfo"` - still not sure how to implement this properly.
```
# Enable build information integration for all images:
find ./build/tmp/work/aero_rsp-oe-linux-gnueabi/core-image-minimal/ -name buildinfo
./build/tmp/work/aero_rsp-oe-linux-gnueabi/core-image-minimal/1.0/rootfs/etc/buildinfo
```

### 7. Definition of build type variables to control development or release builds
```
export BB_ENV_PASSTHROUGH_ADDITIONS="$BB_ENV_PASSTHROUGH_ADDITIONS IMAGE_TYPE"
```
- `IMAGE_TYPE="fab" bitbake core-image-minimal`: generates a fab image
- `IMAGE_TYPE="dev" bitbake core-image-minimal`: generates a dev image



## Troubleshooting

### Build Error: Postinstall Intercept Hook Failed
**Error**: `The postinstall intercept hook 'update_gio_module_cache' failed`

**Solution**: `git restore meta-layers repos` (still don't know why there is modifications in those repo)

### Image Mounting:
```bash
sudo mount -o loop,offset=$((278528*512)) core-image-minimal-aero-rsp.rootfs.wic /tmp/root
sudo mount -o loop,offset=$((8192*512)) core-image-minimal-aero-rsp.rootfs.wic /tmp/boot
```

## Getting Started

1. Clone this repository
2. Ensure Docker is installed and running
3. Run the KAS build:
   ```bash
   kas-container build kas-prj.yml
   ```
4. Flash the generated image to SD card using Balena Etcher or dd command
5. Connect FTDI adapter and boot the system

## Contributing

This is a learning project documenting my Yocto development journey. Feel free to suggest improvements or share your own experiences!

## License

This project is for educational purposes.


![ZKf5OzdXdjtRu](https://github.com/user-attachments/assets/13555cf8-3412-4455-a005-7a86fd6ecf34)

