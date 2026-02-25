
# Customized Linux Image for Raspberry Pi Zero 2 W with Yocto

A custom embedded Linux distribution built with Yocto Project for Raspberry Pi Zero 2 W, featuring custom machine configuration, kernel optimizations, device tree overlays, and kernel modules.

<img width="1280" height="640" alt="raspiandyocto" src="https://github.com/user-attachments/assets/3f6bb7a7-cc33-4849-96f7-d5d70bf5dba2" />

## Hardware Requirements

-   Only Raspberry Pi Zero 2 W
## Features

- [x] Kernel optimization (Fast Boot)
- [x] U-Boot Integration
- [x] Storage Encryption (dm-crypt/LUKS)
- [x] Initramfs Integration
- [x] OTA Update System (RAUC) : A/B Partition Scheme + adaptive update + bundle encryption
- [x] User & Access Management
- [x] CVE scanning : Automated vulnerability checks

- [ ] SDK
- [ ] OPTEE integration
- [ ] SELinux
- [ ] RAUC Hawkbit (Cloud-based)
- [ ] A Yocto-based OTA update parser(libFuzzer/AFL++)


## Requirements
- Docker installed 
- Kas installed : `pip3 install kas`
## How to build
Dev image:

    kas-container build kas/kas-dev.yml

Prod image:

    kas-container build kas/kas-dev.yml

## Info
- If you want to see all the project steps and what I learned, check **steps.md** in **Doc/steps/**.

