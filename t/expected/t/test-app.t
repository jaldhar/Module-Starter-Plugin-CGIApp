#!perl -T
#
use strict;
use warnings;
use Test::More tests => 1;
use Test::WWW::Mechanize::CGIApp;
use Foo;

my $mech = Test::WWW::Mechanize::CGIApp->new;

$mech->app(
    sub {
        my $app = Foo->new(PARAMS => {

        });
        $app->run();
    }
);

$mech->get_ok();

