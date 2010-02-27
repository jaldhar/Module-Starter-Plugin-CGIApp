#
# $Id$
#
package common;
use base qw( Exporter );
use warnings;
use strict;
use blib;
use Cwd qw( cwd );
use English qw( -no_match_vars );
use File::Basename;
use File::Copy::Recursive qw( dircopy );
use File::DirCompare;
use File::Path qw( mkpath rmtree );
use File::Spec;
# this has to go before Module::Starter to affect it
use Test::MockTime qw( set_fixed_time restore_time );
use Module::Starter qw(
    Module::Starter::Simple
    Module::Starter::Plugin::Template
    Module::Starter::Plugin::CGIApp
);
use Module::Starter::App;
use POSIX qw( tzset );
use Test::More;

=head1 NAME

common - common functions and variables for this modules tests

=head1 VERSION

Version 1.2

=cut

our $VERSION = '1.3';

our @EXPORT = qw/ run_tests /;


sub compare_trees {
    my ($old, $new, $different, $extra, $missing) = @_;

    File::DirCompare->compare($old, $new, sub {
        my ($expected, $got) = @_;

        if (!$expected) {
            push @{$extra}, $got;
        }
        elsif (!$got) {
            push @{$missing}, $expected;
        }
        else {
            push @{$different}, $got;
        }
    });
}

sub run_tests {
    my ($type, $keep) = @_;

    my %builder = (
        mb   => 'Module::Build',
        mi   => 'Module::Install',
        eumm => 'ExtUtils::MakeMaker',
    );

    my $dir = File::Spec->catdir(cwd, 't');
    my $old = File::Spec->catdir($dir, 'temp');
    my $new = File::Spec->catdir($dir, 'Foo');

    if ( -d $old ) {
        rmtree $old || die "$OS_ERROR\n";
    }
    if ( -d $new ) {
        rmtree $new || die "$OS_ERROR\n";
    }

    mkpath $old or die "$OS_ERROR\n";
    dircopy 't/expected', $old or die "$OS_ERROR\n";
    dircopy "t/$type", $old or die "$OS_ERROR\n";

    $ENV{MODULE_STARTER_DIR} = $dir;
    $ENV{MODULE_TEMPLATE_DIR} =
        File::Spec->catdir(  dirname($INC{'Module/Starter/Plugin/CGIApp.pm'}), 
        'CGIApp','templates' );
    $ENV{TZ} = 'UTC';
    tzset();
    set_fixed_time('2010-01-01T00:00:00Z');
    Module::Starter->create_distro(
        modules => [ 'Foo' ], 
        dir     => $new,
        author  => 'Jaldhar H. Vyas', 
        email   => 'jaldhar@braincells.com',
        builder => $builder{$type},
    );
    restore_time();
    
    my (@different, @extra, @missing);

    plan tests => 3;
    compare_trees($old, $new, \@different, \@extra, \@missing);
    is(scalar @different, 0, 'different files') || diag join "\n", @different;
    is(scalar @extra, 0, 'extra files') || diag join "\n", @extra;
    is(scalar @missing, 0, 'missing files') || diag join "\n", @missing;

    if ( -d $old && !defined $keep) {
        rmtree $old || die "$OS_ERROR\n";
    }

    if ( -d $new && !defined $keep) {
        rmtree $new || die "$OS_ERROR\n";
    }

    return;
}

1;
