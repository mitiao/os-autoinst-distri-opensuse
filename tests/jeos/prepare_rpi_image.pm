# SUSE's openQA tests
#
# Copyright © 2018 SUSE LLC
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.

# Summary: Decompress RPi raw.xz image, resize to 16GB, convert to qcow2 and upload as asset
# Maintainer: Tomas Hehejik <thehejik@suse.com>

use base "opensusebasetest";
use strict;
use warnings;
use testapi;
use utils 'zypper_call';

sub run {
    my $rawname       = get_required_var('HDD_1_NAME');
    my $rpi_image_url = autoinst_url("/assets/hdd/$rawname");

    (my $rpi_image_rawxz = $rpi_image_url) =~ s/.*\///;
    (my $rpi_image_raw   = $rpi_image_rawxz) =~ s/\.[^.]+$//;
    (my $rpi_image_qcow2 = $rpi_image_raw) =~ s/\.raw/\.qcow2/;

    select_console('root-console');

    zypper_call('ref');
    zypper_call('in --no-recommends qemu-tools');

    # Download, prepare and upload the image
    assert_script_run("time curl --fail -s -O -L $rpi_image_url");
    assert_script_run("time unxz $rpi_image_rawxz",                                            600);
    assert_script_run("time qemu-img resize -f raw $rpi_image_raw 24G",                        600);
    assert_script_run("time qemu-img convert -f raw -O qcow2 $rpi_image_raw $rpi_image_qcow2", 600);
    upload_asset("$rpi_image_qcow2", 1);
}

1;
