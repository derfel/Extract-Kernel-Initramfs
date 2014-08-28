# Extract Kernel Initramfs
---

 * This is an updated version of the script found at
   * https://github.com/davidmroth/Extract-Kernel-Initramfs

 * The problem with that script is that it is incredibly slow (dd bs=1).

 * It did not properly extract my archive image due to only attempting
   to extract the first bytes that appears to be an archive.

 * ChangeLog:
  * Refactored code (a lot)
  * use tail instead of dd for increased speed.
  * loop signature sequences on failure of extraction

 * Using Extract Kernel Initramfs (eki):
  * Use ```eki vmlinuz.img``` to view the archive contents
  * Use ```eki -x vmlinuz.img``` to extract to $PWD/vmlinuz.img.cpio as cpio archive
  * Use ```eki -d vmlinuz.img``` to extract to $PWD/vmlinuz.img.root as directory
  * Use ```eki -o myoutput -(x|d) vmlinuz.img``` to specify an output file/directory.
  * Use ```eki -h``` to display help.

## Building
---

There is no "building" involved, simply run:
```sh
$ ./concat
# or
$ make
```
This concats all the necessary \*.sh files into one script named 'eki'.

## Environment Configuration Options

The following environment variables can be used

| Variable | Description |
| -------- | ------------|
| DEBUG    | Non-blank value enables debug messages |
| TMPDIR   | prefix to mktemp files (read mktemp(1)) |
| KEEP_FILES | Non-blank value enables keeping of temporary files |

## Command Line Configuration Options

|   Option   | Description |
| ---------- | ----------- |
| -q         | Don't extract archive, only query (cpio -t) |
| -o <path>  | output filename / directory path |
| -d         | extract archive to directory root |
| -x         | extract archive as cpio archive |
| -h         | outputs help information |
| no options | same as -q option |

## Bugs?!?
---

Every program has got them right? Well ok, here's the deal. I've only tested
this program on a gzip compressed kernel that had a gzip compressed internal
cpio archive. I copied the lzma/bzip2/etc stuff over from the original unpack-
initramfs script and *hopefully* it works. As I have not tested the lzma/bzip2
portion of this script it may however fail you.

*If you test the lzma/bzip2/cpio stuff, please be so kind as to let me know so
I can update this README. Thank You!*

While the compression schemes can be determed for the cpio archive the kernel
compression is still hardcoded to use "gzip". In theory it would not be hard
to do some slight refactoring to the uncompress_kernel() function and have it
use the use_signature() function. But as this has already used more time than
I intended I will not currently be implementing said feature. (As it would
also require testing.)

If you find a bug or as stated above verify a feature, please do not hesitate
to contact me via [jkinsella spiryx net]. (You can figure that out right?)
Another place I can be reached is zer0python@ircs://irc.freenode.net/peltkore

### Source Files
---

| Filename | Details |
| -------- | ------- |
| unpack-initramfs | original script that 'eki' is based on (kept for whatever reason) |
| -------- | ------- |
| main.sh | main invocation of eki |
| archive.sh | Search for cpio archive in kernel image |
| cdetect.sh | Uncompress kernel and detect compression functions |
| header.sh | Header for eki script includes environment settings |
| helper.sh | Mostly 1 line helper functions for convenience |
| signature.sh | Supported compression signatures |

### Build Files
---

| Filename | Details |
| -------- | ------- |
| Makefile | wrapper to run the concat shell script |
| concat | shell script to concat eki source files together |

### Misc files
---
| Filename | Details |
| -------- | ------- |
| README.md | this file |
| .gitignore | The gitignore file, heh |

#### Example output
---
```
~/src/eki[sodapipe]$ ./eki -o image.cpio -x Bootx64.efi
-I- Extract Kernel Initramfs (eki) v0.2a
-I- Based on http://tinyurl.com/nclkczx and  http://tinyurl.com/49aos4h
-I- Source available at https://github.com/jotaki/ Extract-Kernel-Initramfs
-I- =============================
-I- Bootstrapping...
-I- Bootstrapping complete
-I- Extracting compressed kernel image from file
-I-   > kernel image: Bootx64.efi
-I-   > kernel image size: 10230512
-I-   > compression scheme: gzip
-I-   > position: 17332
-I-   > size after strip: 10213180
-I- Detecting compression type
-I- Detected 2 potential archives
-I- Trying #1
-I-   > ... Failed
-I- Trying #2
-I-   > ... Success
-I-   > ... Success
~/src/eki[sodapipe]$ ls -l image.cpio
-rw------- 1 jk jk 9377286 Aug 27 20:41 image.cpio
~/src/eki[sodapipe]$ cpio -t < image.cpio | head -10
17833 blocks
etc
etc/lvm
lib64
init
sys
proc
root
usr
lib
lib/libdevmapper-event-lvm2thin.so
~/src/eki[sodapipe]$ ./eki -o root -d Bootx64.efi
-I- Extract Kernel Initramfs (eki) v0.2a
-I- Based on http://tinyurl.com/nclkczx and  http://tinyurl.com/49aos4h
-I- Source available at https://github.com/jotaki/ Extract-Kernel-Initramfs
-I- =============================
-I- Bootstrapping...
-I- Bootstrapping complete
-I- Extracting compressed kernel image from file
-I-   > kernel image: Bootx64.efi
-I-   > kernel image size: 10230512
-I-   > compression scheme: gzip
-I-   > position: 17332
-I-   > size after strip: 10213180
-I- Detecting compression type
-I- Detected 2 potential archives
-I- Trying #1
-I-   > ... Failed
-I- Trying #2
-I-   > ... Success
-I-   > ... Success
/home/jk/src/eki
~/src/eki[sodapipe]$ ls -ld root
drwxr-xr-x 10 jk jk 4096 Aug 27 20:42 root
~/src/eki[sodapipe]$ find root | head -15
root
root/init
root/dev
root/dev/vc
root/dev/vc/0
root/dev/mapper
root/bin
root/bin/sh
root/bin/cat
root/bin/vgchange
root/bin/vgscan
root/bin/switch_root
root/bin/lvm
root/bin/cryptsetup
root/bin/sleep
```
