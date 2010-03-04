use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Foo',
    license             => 'perl',
    dist_author         => 'Jaldhar H. Vyas <jaldhar@braincells.com>',
    dist_version_from   => 'lib/Foo.pm',
    tmpl_files          => eval {
        my %tmpls; File::Find::find(
            {
                wanted => sub {
                    if ( -f $_ ) {
                        $tmpls{$File::Find::name} = $File::Find::name;
                    }
                },
            },
            'lib/Foo/templates',
        );
        return \%tmpls;
    },
    build_requires => {
        'Test::More'                    => 0,
        'Test::WWW::Mechanize::CGIApp'  => 0,
    },
    requires => {
        'CGI::Application'              => 4.04,
        'HTML::Template'                => 0,
    },
    add_to_cleanup      => [ 'Foo-*' ],
    create_makefile_pl  => 'traditional',
    sign                => 1,
);

$builder->add_build_element('tmpl');
$builder->create_build_script();

