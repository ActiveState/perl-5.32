#!/usr/bin/perl

use strict;
use warnings;

use lib q(.);
use ActiveStateSetup qw(create_shortcut create_file_assoc);
use File::Path qw( mkpath );
use File::Spec::Functions qw(catfile);
use Win32;

my $start_menu_path = Win32::GetFolderPath(Win32::CSIDL_STARTMENU());
my $start_menu_base = catfile($start_menu_path, 'ActiveState');

mkpath($start_menu_base);

my $cmd = catfile(qw(C: Users martin AppData Local activestate fda04c18 bin perl.exe));
# Overwrite command from first command line argument
if (@ARGV) {
  $cmd = $ARGV[0];
}

create_shortcut($cmd, q(), catfile($start_menu_base, 'Perl.lnk'));

create_file_assoc($cmd, ['.pl', '.perl']);

1;

