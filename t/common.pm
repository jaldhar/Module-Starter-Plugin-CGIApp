#
# $Id$
#
package common;
use base qw( Exporter );
use warnings;
use strict;
use Cwd qw( cwd );
use English qw( -no_match_vars );
use File::Spec;

=head1 NAME

common - common functions and variables for this modules tests

=head1 VERSION

Version 1.0

=cut

our $VERSION = '1.0';

our @EXPORT = qw/ $cgiapp_starter $dir $filespec $root &untaint_path /;

our $filespec;
if ($OSNAME =~ /win/i) {
    $filespec =
        qr{ (\A(?:[[:alpha:]]:)?[ \\ \. \- [:space:] [:word:] ]+)\z }msx;
}
else {
    $filespec = qr{ (\A[- + @ [:word:] . / ]+)\z }msx;
}

# q{} q{} ensures an extra directory seperator at the end.
our $dir  = untaint_path( File::Spec->catfile(cwd, 't', q{}, q{}), '$dir'  );

our $root = untaint_path( File::Spec->catdir($dir, 'Foo'),         '$root' );

our $perl = untaint_path( $EXECUTABLE_NAME,                        '$perl' );
if ($OSNAME =~ /win/i) {
    # Perl must be able to find cmd.exe, so add %WINDOWS%\system32 to path
    my $system32_dir =
         untaint_path( File::Spec->catdir($ENV{'SystemRoot'},'system32'),
            '$system32_dir'
    );
    $ENV{'PATH'} = $system32_dir;
}
else {
    # Path can be empty on UNIX.
    $ENV{PATH} = undef;
}

our $cgiapp_starter;
if ($OSNAME =~ /win/i) {
    $cgiapp_starter = qq{ set MODULE_STARTER_DIR=$dir && cd $dir && $perl -Mblib ../script/cgiapp-starter --module=Foo --author="Jaldhar H. Vyas" --email=jaldhar\@braincells.com };
}
else {
    $cgiapp_starter = qq{ MODULE_STARTER_DIR=$dir ; export MODULE_STARTER_DIR ; cd $dir ; $perl -Mblib ../script/cgiapp-starter --module=Foo --author="Jaldhar H. Vyas" --email=jaldhar\@braincells.com };
}

sub untaint_path {
    my ( $path, $description ) = @_;

    if ( !( $path =~ $filespec ) ) {
         die "$description is tainted.\n";
    }

    return $1;
}

1;
