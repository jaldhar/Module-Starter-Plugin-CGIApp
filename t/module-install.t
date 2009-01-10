#!perl
#
# $Id$
#
use warnings;
use strict;
use English qw( -no_match_vars );
use File::Find qw();
use File::Path qw( rmtree );
use Test::More;
use lib './t';
use common;

qx{ $cgiapp_starter --mi };

my @expected_files = (
    'Foo',                   'Foo/lib',
    'Foo/lib/Foo.pm',        'Foo/lib/Foo',
    'Foo/lib/Foo/templates', 'Foo/lib/Foo/templates/runmode1.html',
    'Foo/t',                 'Foo/t/www',
    'Foo/t/pod-coverage.t',  'Foo/t/pod.t',
    'Foo/t/test-app.t',      'Foo/t/01-load.t',
    'Foo/t/perl-critic.t',   'Foo/t/boilerplate.t',
    'Foo/t/00-signature.t',  'Foo/t/perlcriticrc',
    'Foo/Makefile.PL',       'Foo/Changes',
    'Foo/README',            'Foo/MANIFEST.SKIP',
    'Foo/MANIFEST',          'Foo/server.pl',
);

my %got_files;
foreach my $file (@expected_files) {
    $got_files{$file} = -1;
}

File::Find::find(
    {   no_chdir => 1,
        wanted  => sub {
            if ( -e $File::Find::name ) {
                my $name = $File::Find::name;
                $name =~ s{\A\Q$dir\E}{}msx;
                $got_files{$name} = grep { $_ eq $name } @expected_files;
            }
            return;
            }
    },
    $root,
);

plan tests => ( scalar keys %got_files ) * 2;

foreach my $file ( keys %got_files ) {
    ok( $got_files{$file} > -1, "Missing file $file" );
}

foreach my $file ( keys %got_files ) {
    ok( $got_files{$file}, "Extra file $file" );
}

END {
    if ( -d $root ) {
        rmtree $root || die "$OS_ERROR\n";
    }
}
