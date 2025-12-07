# How Generate `boot.img` file


```
PS C:\windowFiles\x86-64-OS\The+First+Program> bximage

ERROR: Parameter -func missing - switching to interactive mode.

========================================================================
                                bximage
  Disk Image Creation / Conversion / Resize and Commit Tool for Bochs
                                  $Id$
========================================================================

1. Create new floppy or hard disk image
2. Convert hard disk image to other format (mode)
3. Resize hard disk image
4. Commit 'undoable' redolog to base image
5. Disk image info

0. Quit

Please choose one [0] 1

Create image

Do you want to create a floppy disk image or a hard disk image?
Please type hd or fd. [hd]

What kind of image should I create?
Please type flat, sparse, growing, vpc or vmware4. [flat]

Choose the size of hard disk sectors.
Please type 512, 1024 or 4096. [512]

Enter the hard disk size in megabytes, between 10 and 8257535
[10]

What should be the name of the image?
[c.img] myboot.img

Creating hard disk image 'myboot.img' with CHS=20/16/63 (sector size = 512)

The following line should appear in your bochsrc:
  ata0-master: type=disk, path="myboot.img", mode=flat
(The line is stored in your windows clipboard, use CTRL-V to paste)

```