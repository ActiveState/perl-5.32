use ExtUtils::MakeMaker;
use File::ShareDir::Install;

install_share('setup_files');

WriteMakefile(
    NAME          => 'ActiveState::Setup',
    VERSION_FROM  => 'lib/ActiveState/Setup.pm',
    AUTHOR        => 'ActiveState <support@activestate.com>',
    ABSTRACT      => 'Setup and installer utilities for Perl projects using the ActiveState platform',
    BUILD_REQUIRES => {
        'ExtUtils::MakeMaker'     => 0,
        'File::ShareDir::Install' => 0,
    },
    LICENSE => 'mit',
    PREREQ_PM => {
        'File::Path'         => 0,
        'File::Basename'     => 0,
        'File::ShareDir'     => 0,
        'Win32'              => 0,
        'Win32::API'         => 0,
        'Win32::Shortcut'    => 0,
        'Win32::TieRegistry' => 0,
    },
);
