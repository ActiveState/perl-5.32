#!/usr/bin/perl -w

package  ActiveStateSetup;

use strict;
use warnings;

use Exporter 'import';
our @EXPORT_OK = qw(create_shortcut create_file_assoc);

use Win32::API;
use Win32::Shortcut;
use Win32::TieRegistry;
use File::Basename qw(basename);

our $VERSION           = '0.01';
my $SHCNE_ASSOCCHANGED = 0x8_000_000;
my $SCNF_FLUSH         = 0x1000;

# Import Win32 function: `void SHChangeNotify(int eventId, int flags, IntPtr item1, IntPtr item2)`

my $SHChangeNotify = Win32::API::More->new( 'shell32', 'SHChangeNotify', 'iiPP', 'V' );
if ( not defined $SHChangeNotify ) {
    die "Can't import SHChangeNotify: ${^E}\n";
}

sub update_win32_shell() {
    $SHChangeNotify->Call( $SHCNE_ASSOCCHANGED, $SCNF_FLUSH, 0, 0 );
    return;
}

sub create_shortcut {
    my $target  = shift;
    my $icon    = shift;
    my $lnkPath = shift;

    if ( -e $lnkPath ) {
        unlink $lnkPath;
    }

    print "Creating shortcut: $lnkPath -> $target\n";
    my $LINK = Win32::Shortcut->new();
    $LINK->{'Path'} = $target;

    # $LINK->{'WorkingDirectory'} = '';
    $LINK->{'IconLocation'} = $icon;
    $LINK->{'IconNumber'}   = 0;
    $LINK->Save($lnkPath);
    $LINK->Close();

    return;
}

sub create_file_assoc {
    my $cmd       = shift;
    my $assocsRef = shift;

    my $cmd_name = basename($cmd);
    my $prog_id  = "ActiveState.${cmd_name}";

    # file type description
    $Registry->{"CUser\\Software\\Classes\\${prog_id}\\"} = {
        "\\" => "$cmd_name document", 
        "shell\\" => {
            "open\\" => {
                "command\\" => {
                    "\\" => "$cmd %1 %*"
                }
            }
        }
    };

    foreach (@$assocsRef) {
        print "Creating file association: $_: $prog_id\n";
        $Registry->{"CUser\\Software\\Classes\\$_\\"} = {"" => $prog_id};
    }

    update_win32_shell();

    return;
}

1;