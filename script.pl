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

print <<EOT;
      You are now in an 'activated state', this will give you a virtual environment to work in that doesn't affect the rest of your system.

      Your 'activated state' allows you to manage packages, scripts, secrets and more via the activestate.yaml file at the root of your project directory.

      To manage packages use the `state packages` command. For more information about package management, use `state packages --help`. For more information about the State Tool use `state help`.

      To access additional features of the ActiveState Platform and use a web-based interface for managing your project, you can visit https://platform.activestate.com/ActiveState/Perl532-BundlesRC.

      Edit your activestate.yaml to remove this message.

      To get started, run `state run learn` to view a quick start guide of commonly used commands.
EOT

1;

