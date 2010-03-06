use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    dist_name           => 'Example-Dist',
    module_name         => 'Foo::Bar',
    dist_abstract       => '',
    dist_author         => 'Jaldhar H. Vyas <jaldhar@braincells.com>',
    license             => 'perl',
    dist_version        => '0.01',
    tmpl_files          => eval {
        my %tmpls; File::Find::find(
            {
                wanted => sub {
                    if ( -f $_ ) {
                        $tmpls{$File::Find::name} = $File::Find::name;
                    }
                },
            },
            'lib/Example/Dist/templates',
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
    add_to_cleanup      => [ 'Example-Dist-*' ],
    create_makefile_pl  => 'traditional',
    sign                => 1,
);

$builder->add_build_element('tmpl');
$builder->create_build_script();

