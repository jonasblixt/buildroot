#!/usr/bin/env bash

set -e

BPAK=$HOST_DIR/usr/bin/bpak
V=-vvv

IMG=$BINARIES_DIR/boot.bpak
PKG_UUID=76dff3ba-5529-4964-bf49-4e8856e93242

ROOTFS_IMG=$BINARIES_DIR/rootfs.bpak
ROOTFS_PKG_UUID=0888b0fa-9c48-4524-9845-06a641b61edd

OVERLAY_IMG=$BINARIES_DIR/overlay.bpak
OVERLAY_PKG_UUID=b0a9cc81-9c40-4e05-bdc4-63c0a2d64104

ROTE_IMG=$BINARIES_DIR/rote.bpak
ROTE_PKG_UUID=5df103ef-e774-450b-95c5-1fef51ceec28

echo "Using $BPAK"

gen_boot_bpak()
{
    $BPAK create $IMG -Y --hash-kind sha512 --signature-kind secp521r1 $V

    $BPAK add $IMG --meta bpak-package --from-string $PKG_UUID --encoder uuid $V

    $BPAK add $IMG --meta pb-load-addr --from-string 0x82000000 --part-ref kernel \
                          --encoder integer $V

    $BPAK add $IMG --meta pb-load-addr --from-string 0x80800000 --part-ref dt \
                        --encoder integer $V

    $BPAK add $IMG --meta pb-load-addr --from-string 0x81000000 --part-ref ramdisk \
                        --encoder integer $V

    $BPAK add $IMG --meta pb-load-addr --from-string 0x80000000 --part-ref atf \
                        --encoder integer $V

    $BPAK add $IMG --meta pb-load-addr --from-string 0xfe000000 --part-ref optee \
                        --encoder integer $V

    $BPAK transport $IMG --add --part-ref kernel --encoder bsdiff \
                                                 --decoder bspatch $V

    $BPAK transport $IMG --add --part-ref dt --encoder bsdiff \
                                             --decoder bspatch $V

    $BPAK transport $IMG --add --part-ref ramdisk --encoder bsdiff \
                                                  --decoder bspatch $V

    $BPAK transport $IMG --add --part-ref atf --encoder bsdiff \
                                              --decoder bspatch $V

    $BPAK transport $IMG --add --part-ref optee --encoder bsdiff \
                                                --decoder bspatch $V

    # Device Tree Blob
    $BPAK add $IMG --part dt \
                   --from-file $BINARIES_DIR/imx8qxmek_pb.dtb $V

    # ATF
    $BPAK add $IMG --part atf \
                   --from-file $BINARIES_DIR/bl31.bin $V

    # Initial ramdisk
    $BPAK add $IMG --part ramdisk \
                   --from-file $BINARIES_DIR/kickstart-initrd.cpio $V

    # Linux Kernel
    $BPAK add $IMG --part kernel \
                   --from-file $BINARIES_DIR/Image $V

    # Optee
    $BPAK add $IMG --part optee \
                   --from-file $BINARIES_DIR/tee-pager_v2.bin $V

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
                          --keystore-id ks-internal $V

    $BPAK sign $ROOTFS_IMG --key board/jonas/pki/secp256r1-key-pair.pem
}

gen_rot_extension ()
{
    echo Generating RoT extension
    $BPAK create $ROTE_IMG -Y --hash-kind sha256 --signature-kind prime256v1 $V

    $BPAK add $ROTE_IMG --meta bpak-package --from-string $ROTE_PKG_UUID \
                        --encoder uuid $V

    $BPAK add $ROTE_IMG --meta bpak-keystore-id \
                        --from-string rot-extension \
                        --encoder id $V

    $BPAK add $ROTE_IMG --part pb-development \
                   --from-file board/jonas/pki/secp256r1-pub-key.der $V

    $BPAK add $ROTE_IMG --part pb-development2 \
                   --from-file board/jonas/pki/secp384r1-pub-key.der $V

    $BPAK add $ROTE_IMG --part pb-development3 \
                   --from-file board/jonas/pki/secp521r1-pub-key.der $V

    $BPAK add $ROTE_IMG --part pb-development4 \
                   --from-file board/jonas/pki/dev_rsa_public.der $V

    $BPAK set $ROTE_IMG --key-id pb-development \
                        --keystore-id ks-internal $V

    $BPAK sign $ROTE_IMG --key board/jonas/pki/secp256r1-key-pair.pem
}

gen_overlay ()
{
    echo Generating overlay
    $BPAK create $OVERLAY_IMG -Y

    $BPAK add $OVERLAY_IMG --meta bpak-package \
                          --from-string $OVERLAY_PKG_UUID \
                          --encoder uuid $V

    $BPAK transport $OVERLAY_IMG --add --part fs \
                                --encoder heatshrink-encode \
                                --decoder heatshrink-decode $V

    $BPAK transport $OVERLAY_IMG --add --part fs-hash-tree \
                         --encoder remove-data \
                         --decoder merkle-generate $V

    rm -rf $BINARIES_DIR/overlay
    rm -f $BINARIES_DIR/overlay.squash
    mkdir -p $BINARIES_DIR/overlay
    dd if=/dev/urandom of=$BINARIES_DIR/overlay/overlay_image bs=1k count=16

    mksquashfs $BINARIES_DIR/overlay \
               $BINARIES_DIR/overlay.squash -noI -noD -noF -noX

    $BPAK add $OVERLAY_IMG --part fs \
                   --from-file $BINARIES_DIR/overlay.squash \
                   --set-flag dont-hash \
                   --encoder merkle $V

    $BPAK set $OVERLAY_IMG --key-id pb-development \
                           --keystore-id rot-extension $V

    $BPAK sign $OVERLAY_IMG --key board/jonas/pki/secp256r1-key-pair.pem
}

gen_boot_bpak $@
gen_rootfs_bpak $@
gen_rot_extension $@
gen_overlay $@
