#!/usr/bin/perl -w

package  Setup;

use strict;
use warnings;

use Exporter 'import';
our @EXPORT_OK = qw(create_internet_shortcuts create_shortcuts create_file_assoc);

use lib q(.);
use File::Path qw( mkpath );
use File::Spec::Functions qw(catfile);
use File::Basename qw(basename);
use Config;
use Cwd qw(cwd);

use Win32;
use Win32::API;
use Win32::Shortcut;
use Win32::TieRegistry;

our $VERSION           = '0.02';
my $SHCNE_ASSOCCHANGED = 0x8_000_000;
my $SCNF_FLUSH         = 0x1000;

my $ORGANIZATION = 'ActiveState';
my $PROJECT      = 'Perl-5.32';
my $NAMESPACE    = "$ORGANIZATION/$PROJECT";
my $PLATFORM_URL = "https://platform.activestate.com/$NAMESPACE";
my $STATE_ICO    = "state.ico";
my $WEB_ICO      = "web.ico";

# Import Win32 function: `void SHChangeNotify(int eventId, int flags, IntPtr item1, IntPtr item2)`

my $SHChangeNotify = Win32::API::More->new( 'shell32', 'SHChangeNotify', 'iiPP', 'V' );
if ( not defined $SHChangeNotify ) {
    die "Can't import SHChangeNotify: ${^E}\n";
}

sub update_win32_shell {
    $SHChangeNotify->Call( $SHCNE_ASSOCCHANGED, $SCNF_FLUSH, 0, 0 );
    return;
}

sub desktop_dir_path {
    return Win32::GetFolderPath(Win32::CSIDL_DESKTOPDIRECTORY());
}

sub start_menu_path {
    return Win32::GetFolderPath(Win32::CSIDL_STARTMENU());
}

sub make_path {
    my $base = shift;

    unless (-d $base) {
        my $success = mkpath($base);
	die "Couldn't create path '$base': $!" unless $success == 1;
    }
}

sub create_internet_shortcut {
    my $target  = shift;
    my $lnkPath = shift;
    my $iconPath = shift;

    if ( -e $lnkPath ) {
        unlink $lnkPath;
    }

    my $str = <<END;
[InternetShortcut]
URL=${target}
IconFile=${iconPath}
IconIndex=0
END

    open(FH, '>', $lnkPath) or die "Couldn't create internet shortcut '$target': $!";
    print FH $str;
    close(FH);

    return;
}

sub create_shortcut {
    my $target   = shift;
    my $args     = shift;
    my $icon     = shift;
    my $lnkPath  = shift;
    my $location = shift;

    if ( -e $lnkPath ) {
        unlink $lnkPath;
    }

    #print "Creating application shortcut: $lnkPath -> $target\n";
    my $LINK = Win32::Shortcut->new();
    $LINK->{'Path'}             = $target;
    $LINK->{'Arguments'}        = $args;
    $LINK->{'IconLocation'}     = $icon;
    $LINK->{'IconNumber'}       = 0;
    $LINK->{'WorkingDirectory'} = $location;
    $LINK->Save($lnkPath);
    $LINK->Close();

    return;
}

sub create_internet_shortcuts {
    my $target  = $PLATFORM_URL;
    my $lnkName = "$NAMESPACE Web.url";
    $lnkName =~ s#/# #;
    my $icon = catfile(cwd, $WEB_ICO);

    my $start_menu_base = catfile(start_menu_path(), $ORGANIZATION);
    make_path($start_menu_base);
    my $startLnkPath = catfile($start_menu_base, $lnkName);
    create_internet_shortcut($target, $startLnkPath, $icon);

    my $dsktpLnkPath = catfile(desktop_dir_path(), $lnkName);
    create_internet_shortcut($target, $dsktpLnkPath, $icon);

    return;
}

sub create_shortcuts {
    my $target  = "%windir%\\system32\\cmd.exe";
    my $args     = "/k state activate";
    my $icon = catfile(cwd, $STATE_ICO);
    my $lnkName = "$NAMESPACE CLI.lnk";
    $lnkName =~ s#/# #;

    my $start_menu_base = catfile(start_menu_path(), $ORGANIZATION);
    make_path($start_menu_base);
    my $startLnkPath = catfile($start_menu_base, $lnkName);
    create_shortcut($target, $args, $icon, $startLnkPath, cwd);

    my $dsktpLnkPath = catfile(desktop_dir_path(), $lnkName);
    create_shortcut($target, $args, $icon, $dsktpLnkPath, cwd);

    return;
}

sub create_file_assoc {
    my $cmd       = $Config{perlpath};
    my $assocsRef = ['.pl', '.perl'];

    my $cmd_name = basename($cmd);
    my $prog_id  = "$ORGANIZATION.${cmd_name}";

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
        #print "Creating file association: $_: $prog_id\n";
        $Registry->{"CUser\\Software\\Classes\\$_\\"} = {"" => $prog_id};
    }

    update_win32_shell();

    return;
}

1;
