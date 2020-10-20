#!/usr/bin/env bash

set -e

BPAK=$HOST_DIR/usr/bin/bpak
V=-vvv

IMG=$BINARIES_DIR/boot.bpak
PKG_UUID=76dff3ba-5529-4964-bf49-4e8856e93242

ROOTFS_IMG=$BINARIES_DIR/rootfs.bpak
ROOTFS_PKG_UUID=0888b0fa-9c48-4524-9845-06a641b61edd

echo "Using $BPAK"

gen_boot_bpak()
{
    $BPAK create $IMG -Y --hash-kind sha256 --signature-kind prime256v1 $V

    $BPAK add $IMG --meta bpak-package --from-string $PKG_UUID --encoder uuid $V

    $BPAK add $IMG --meta pb-load-addr --from-string 0x83000000 --part-ref kernel \
                          --encoder integer $V

    $BPAK add $IMG --meta pb-load-addr --from-string 0x83f00000 --part-ref dt \
                        --encoder integer $V

    $BPAK add $IMG --meta pb-load-addr --from-string 0x84000000 --part-ref ramdisk \
                        --encoder integer $V

    $BPAK transport $IMG --add --part-ref kernel --encoder bsdiff \
                                                 --decoder bspatch $V

    $BPAK transport $IMG --add --part-ref dt --encoder bsdiff \
                                             --decoder bspatch $V

    $BPAK transport $IMG --add --part-ref ramdisk --encoder bsdiff \
                                                  --decoder bspatch $V

    # Device Tree Blob
    $BPAK add $IMG --part dt \
                   --from-file $BINARIES_DIR/jiffy.dtb $V

    # Initial ramdisk
    $BPAK add $IMG --part ramdisk \
                   --from-file $BINARIES_DIR/kickstart-initrd.cpio $V

    # Linux Kernel
    $BPAK add $IMG --part kernel \
                   --from-file $BINARIES_DIR/zImage $V

    echo Signing...
    $BPAK set $IMG --key-id pb-development \
                   --keystore-id pb $V

    $BPAK sign $IMG --key board/jonas/pki/secp256r1-key-pair.pem
}

gen_rootfs_bpak ()
{

    $BPAK create $ROOTFS_IMG -Y

    $BPAK add $ROOTFS_IMG --meta bpak-package \
                          --from-string $ROOTFS_PKG_UUID \
                          --encoder uuid $V

    $BPAK transport $ROOTFS_IMG --add --part fs \
                                --encoder heatshrink-encode \
                                --decoder heatshrink-decode $V

    $BPAK transport $ROOTFS_IMG --add --part fs-hash-tree \
                         --encoder remove-data \
                         --decoder merkle-generate $V

    rm -rf $BINARIES_DIR/rootfs
    rm -f $BINARIES_DIR/root.squash
    mkdir $BINARIES_DIR/rootfs
    tar xf $BINARIES_DIR/rootfs.tar -C $BINARIES_DIR/rootfs

    mksquashfs $BINARIES_DIR/rootfs \
               $BINARIES_DIR/root.squash -noI -noD -noF -noX

    $BPAK add $ROOTFS_IMG --part fs \
                   --from-file $BINARIES_DIR/root.squash \
                   --set-flag dont-hash \
                   --encoder merkle $V

    $BPAK set $ROOTFS_IMG --key-id pb-development \
                   --keystore-id pb-internal $V

    $BPAK sign $ROOTFS_IMG --key board/jonas/pki/secp256r1-key-pair.pem
}

gen_boot_bpak $@
gen_rootfs_bpak $@
