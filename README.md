# Configuration of DanWand image

1. Create SDcard with Raspberry PI OS Lite 32bit (Buster)

    a. Use Raspberry Pi Imager

    b. copy files from pi-config to boot directory

2. Reboot Device

3. Connect to device (raspberrypi.local)

4. install git

5. Install device setup image from github
    git clone https://github.com/peterlholm/wand_os





This project contains a makefile which install / configure elements:

## make raspbian
Reconfigure raspian so only used service are active and python3 available

## make install
Install the required setup raspbian, services, users etc

## make 
display list of available options



# Init new PI Z Wifi

1. Create SD card with image (Raspberry Pi OS Lite (32bit) 11-1-2021, Linux 5.4.83)
1. Configure Boot partition (examples in pi-config)
    * create ssh file
    * create wpa_supplicant.conf
            country=US
            ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
            update_config=1

            network={
                ssid="NETWORK-NAME"
                psk="NETWORK-PASSWORD"
            }
    * files can befound in pi-config folder
    
1. boot Pi system
1. connect terminal
`    
ssh pi@raspberrypi.local (password: raspberry)
`
1. set new password on pi user
1. update sw
```
    sudo apt update
    sudo apt upgrade
```    
1. install git
    * sudo apt install git
   
System usage:
  * disk: ca 1,3 Gbyte
  * ram: 30 Mbyte, 335 Mbyte free
  
* install this project
     Se above



# RPI boot image


EMC : 31 GB (31,268,536,320 bytes)


/sda            Patitions end 1875 Mbyte ()

Model: RPi-MSD- 0001 (scsi)
Disk /dev/sda: 31.3GB
Sector size (logical/physical): 512B/512B
Partition Table: msdos
Disk Flags: 

Number  Start   End     Size    Type     File system  Flags
 1      4194kB  273MB   268MB   primary  fat32        lba
 2      273MB   1875MB  1602MB  primary  ext4

parted) unit b                                                           
(parted) print                                                            
Model: RPi-MSD- 0001 (scsi)
Disk /dev/sda: 31268536320B
Sector size (logical/physical): 512B/512B
Partition Table: msdos
Disk Flags: 

Number  Start       End          Size         Type     File system  Flags
 1      4194304B    272629759B   268435456B   primary  fat32        lba
 2      272629760B  1874853887B  1602224128B  primary  ext4



/dev/sda1       255M   50M  206M  20% /media/peter/boot             215 Mbyte Free
/dev/sda2       1.5G  1.1G  279M  80% /media/peter/rootfs           389 Mbyte Free
/dev/sda1         261108    50938    210170  20% /media/peter/boot
/dev/sda2        1505000  1125216    285168  80% /media/peter/rootfs


   git clone --depth=1 https://github.com/raspberrypi/usbboot  
