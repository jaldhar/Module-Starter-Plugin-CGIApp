#
# $Id$
#
package common;
use base qw( Exporter );
use warnings;
use strict;
use Cwd qw( cwd );
use English qw( -no_match_vars );
use File::Find qw();
use File::Spec;
use Test::More;

=head1 NAME

common - common functions and variables for this modules tests

=head1 VERSION

Version 1.2

=cut

our $VERSION = '1.2';

our @EXPORT = qw/ $cgiapp_starter $dir $root @expected_files &run_tests /;

our $dir  = File::Spec->catdir(cwd, 't');
our $root = File::Spec->catdir($dir, 'Foo');

our $cgiapp_starter;
if ($OSNAME =~ /win/i) {
    $cgiapp_starter = qq{ set MODULE_STARTER_DIR=$dir && cd $dir && $EXECUTABLE_NAME -Mblib ../script/cgiapp-starter --module=Foo --author="Jaldhar H. Vyas" --email=jaldhar\@braincells.com };
}
else {
    $cgiapp_starter = qq{ MODULE_STARTER_DIR=$dir ; export MODULE_STARTER_DIR ; cd $dir ; $EXECUTABLE_NAME -Mblib ../script/cgiapp-starter --module=Foo --author="Jaldhar H. Vyas" --email=jaldhar\@braincells.com };
}

our @expected_files = (
    'Foo',                   'Foo/lib',
    'Foo/lib/Foo.pm',        'Foo/lib/Foo',
    'Foo/lib/Foo/templates', 'Foo/lib/Foo/templates/runmode1.html',
    'Foo/t',                 'Foo/t/www/PUT.STATIC.CONTENT.HERE',
    'Foo/t/pod-coverage.t',  'Foo/t/pod.t',
    'Foo/t/test-app.t',      'Foo/t/01-load.t',
    'Foo/t/perl-critic.t',   'Foo/t/boilerplate.t',
    'Foo/t/00-signature.t',  'Foo/t/perlcriticrc',
    'Foo/Changes',           'Foo/README',
    'Foo/MANIFEST.SKIP',     'Foo/MANIFEST',
    'Foo/server.pl',         'Foo/t/www',
);

my $diag = '';

sub run_tests {
    my %got_files;

    # change / to local directory seperator in @expected_files
    map { $_ = File::Spec->catfile( split m{/}, $_ ) } @expected_files;
    
    # Now start by priming %got_files with the list of files we expect to 
    # exist.  The entry for each file will be given a value of -1
    foreach my $file (@expected_files) {
        $got_files{$file} = -1;
    }

    # Then add all the files that we actually found to %got_files.
    File::Find::find(
        {   no_chdir => 1,
            wanted  => sub {
                if ( -e $File::Find::name ) {
                    my $name = $File::Find::name;
                    $name = File::Spec->abs2rel($name, $dir);
                    # if the file we found is on the list of files expected 
                    # to exist, give its entry in %got_files a value of 1
                    # else the entry gets a value of 0.
                    $got_files{$name} = grep { $_ eq $name } @expected_files;
                    # furthermore if the file we found is on the list of files
                    # expected to exist and its length is non-zero, increase 
                    # the value of its entry in %got_files to 2.
                    if ( $got_files{$name} &&
                        ( -d $File::Find::name || -s $File::Find::name ) ) {
                        $got_files{$name}++;
                    }
                }
                return;
            }
        },
        $root,
    );

    # so to sum up, the value of the %got_files entry for a file can be...
    # -1  if the file is expected to exist but doesn't.
    #  0  if the file is not expected to exist but does.
    #  1  if the file is expected to exist and does but is zero-length.
    #  2  if the file is expected to exist and does and  is bigger than 0
    #     (which we assume means that it is good.)
    plan tests => ( scalar keys %got_files );

    foreach my $file ( keys %got_files ) {
        ok( diagnose_file($got_files{$file}), "$file$diag" );
    }
    
    return;
}

sub diagnose_file {
    my ($file) = @_;
    
    if ( $file == -1 ) {
        $diag = ' is missing';
        return;
    }
    elsif ( $file ==  0 ) {
        $diag = ' is extra';
        return;
    }
    elsif ( $file ==  1 ) {
        $diag = ' is zero-length';
        return;
    }
    $diag = '';
    return 1;
}

1;
