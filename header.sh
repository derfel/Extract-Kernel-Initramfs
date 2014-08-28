#!/bin/bash
# This is an update version of the script found at 
# forum.xda-developers.com/wiki/index.php?title=Extract_initramfs_from_zImage
#
# The problem with that script is that the gzip magic number occasionally
# occurs naturally, meaning that some non-compressed files get uncompressed.
###########################
# 
# This is an updated version of the script found at
#  https://github.com/davidmroth/Extract-Kernel-Initramfs
#
# The problems with that script are documented in the README
###############################################################################

#####
# Configuration options that you really shouldn't need to touch anyway.
DEBUG=${DEBUG:-}
KEEP_FILES=${KEEP_FILES:-}

##
# Should not need to edit below this point.
############################################
VERSION="0.2b"
