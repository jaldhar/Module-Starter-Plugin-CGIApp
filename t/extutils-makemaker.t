#!perl -T
#
# $Id$
#
use warnings;
use strict;
use Cwd qw(cwd);
use English qw( -no_match_vars );
use File::Find qw();
use File::Path qw( rmtree );
use Test::More;

$ENV{PATH} = undef;
my $dir  = untaint_path( cwd . '/t',       '$dir' );
my $perl = untaint_path( $EXECUTABLE_NAME, '$perl' );

qx{ MODULE_STARTER_DIR=$dir/t $perl ./script/cgiapp-starter --module=Foo --author="Jaldhar H. Vyas"  --email=jaldhar\@braincells.com --dir="$dir/Foo" --eumm };

my @expected_files = (
    'Foo/lib/Foo.pm',       'Foo/lib/Foo/templates/runmode1.html',
    'Foo/t/pod-coverage.t', 'Foo/t/pod.t',
    'Foo/t/test-app.t',     'Foo/t/01-load.t',
    'Foo/t/perl-critic.t',  'Foo/t/boilerplate.t',
    'Foo/t/00-signature.t', 'Foo/t/perlcriticrc',
    'Foo/Makefile.PL',      'Foo/Changes',
    'Foo/README',           'Foo/MANIFEST.SKIP',
    'Foo/MANIFEST',         'Foo/server.pl',
);

my %got_files;
foreach my $file (@expected_files) {
    $got_files{$file} = -1;
}

File::Find::find(
    {   untaint => 1,
        wanted  => sub {
            if ( -f $File::Find::name ) {
                my $name = $File::Find::name;
                $name =~ s{^$dir/}{}msx;
                $got_files{$name} = grep { $_ eq $name } @expected_files;
            }
            return;
            }
    },
    "$dir/Foo"
);

plan tests => ( scalar keys %got_files ) * 2;

foreach my $file ( keys %got_files ) {
    ok( $got_files{$file} > -1, "Missing file $file" );
}

foreach my $file ( keys %got_files ) {
    ok( $got_files{$file}, "Extra file $file" );
}

sub untaint_path {
    my ( $path, $description ) = @_;
    if ( !( $path =~ m{ (\A[-+@\w./]+\z) }msx ) ) {
        die "$description is tainted.\n";
    }
    return $1;
}

END {
    if ( -d "$dir/Foo" ) {
        rmtree "$dir/Foo" || die "$OS_ERROR\n";
    }
}
