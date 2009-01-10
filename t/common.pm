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

our $VERSION = '1.1';

our @EXPORT = qw/ $cgiapp_starter $dir $root /;

# q{} q{} ensures an extra directory seperator at the end.
our $dir  = File::Spec->catfile(cwd, 't', q{}, q{});

our $root = File::Spec->catdir($dir, 'Foo');

our $cgiapp_starter;
if ($OSNAME =~ /win/i) {
    $cgiapp_starter = qq{ set MODULE_STARTER_DIR=$dir && cd $dir && $EXECUTABLE_NAME -Mblib ../script/cgiapp-starter --module=Foo --author="Jaldhar H. Vyas" --email=jaldhar\@braincells.com };
}
else {
    $cgiapp_starter = qq{ MODULE_STARTER_DIR=$dir ; export MODULE_STARTER_DIR ; cd $dir ; $EXECUTABLE_NAME -Mblib ../script/cgiapp-starter --module=Foo --author="Jaldhar H. Vyas" --email=jaldhar\@braincells.com };
}

1;
