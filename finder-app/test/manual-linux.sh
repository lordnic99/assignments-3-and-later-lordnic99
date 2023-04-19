#!/bin/bash
# Script outline to install and build kernel.
# Author: Siddhant Jajoo.

# set -e
set -u

OUTDIR=/tmp/aeld

# # check outdir argument
# if [ $# -eq 2 ]; then
#     OUTDIR=$1
# fi

# # create outdir
# mkdir -p ${OUTDIR}
# if [ ! -d $OUTDIR ]; then
#     exit 1
# fi

KERNEL_REPO=git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
KERNEL_VERSION=v5.1.10
BUSYBOX_VERSION=1_33_1
FINDER_APP_DIR=$(realpath $(dirname $0))
ARCH=arm64
CROSS_COMPILE=aarch64-none-linux-gnu-
export PATH=/home/hoang/gcc-arm/bin:$PATH

if [ $# -lt 1 ]; then
    echo "Using default directory ${OUTDIR} for output"
else
    OUTDIR=$1
    echo "Using passed directory ${OUTDIR} for output"
fi

mkdir -p ${OUTDIR}

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/linux-stable" ]; then
    #Clone only if the repository does not exist.
    echo "CLONING GIT LINUX STABLE VERSION ${KERNEL_VERSION} IN ${OUTDIR}"
    git clone ${KERNEL_REPO} --depth 1 --single-branch --branch ${KERNEL_VERSION}
fi
if [ ! -e ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ]; then
    cd linux-stable
    echo "Checking out version ${KERNEL_VERSION}"
    git checkout ${KERNEL_VERSION}

    # TODO: Add your kernel build steps here
    wget https://raw.githubusercontent.com/bwalle/ptxdist-vetero/f1332461242e3245a47b4685bc02153160c0a1dd/patches/linux-5.0/dtc-multiple-definition.patch
    
    echo "Patch Success!"
    echo "Now Building Linux Kernel!"
    make -j4 ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE defconfig  #generate .config file
    make -j4 ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE all        #build all
    git apply dtc-multiple-definition.patch
    make -j4 ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE all
fi

cp ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image $OUTDIR

echo "Adding the Image in outdir"

echo "Creating the staging directory for the root filesystem"
cd "$OUTDIR"
if [ -d "${OUTDIR}/rootfs" ]; then
    echo "Deleting rootfs directory at ${OUTDIR}/rootfs and starting over"
    sudo rm -rf ${OUTDIR}/rootfs
fi

# TODO: Create necessary base directories

cd "$OUTDIR"
mkdir -p rootfs
cd rootfs
mkdir -p bin dev etc home lib lib64 proc sbin sys tmp usr var
mkdir -p usr/bin usr/lib usr/sbin
mkdir -p var/log

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/busybox" ]; then
    git clone git://busybox.net/busybox.git
    cd busybox
    git checkout ${BUSYBOX_VERSION}
    # TODO:  Configure busybox

else
    cd busybox
fi

# TODO: Make and install busybox
make distclean 
make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE defconfig
sed -i 's/CONFIG_EXTRA_CFLAGS=""/CONFIG_EXTRA_CFLAGS="-static"/g' .config 
make -j4 CONFIG_PREFIX=$OUTDIR/rootfs ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE install
cd $OUTDIR/rootfs

echo "Library dependencies"
${CROSS_COMPILE}readelf -a bin/busybox | grep "program interpreter"
${CROSS_COMPILE}readelf -a bin/busybox | grep "Shared library"

# TODO: Add library dependencies to rootfs
echo "No need library dependencies, busybox was build with static linking"

# TODO: Make device nodes
sudo mknod -m 666 dev/null c 1 3
sudo mknod -m 600 dev/console c 5 1

# TODO: Clean and build the writer utility
cd $FINDER_APP_DIR
make clean
make CROSS_COMPILE

# TODO: Copy the finder related scripts and executables to the /home directory
# on the target rootfs
cd $FINDER_APP_DIR
# cp -R ../* $OUTDIR/rootfs/home

# TODO: Chown the root directory
cd $OUTDIR/rootfs
sudo chown -R root:root *

# TODO: Create initramfs.cpio.gz
cd $OUTDIR/rootfs
find . | cpio -H newc -ov --owner root:root > ${OUTDIR}/initramfs.cpio
gzip -f $OUTDIR/initramfs.cpio