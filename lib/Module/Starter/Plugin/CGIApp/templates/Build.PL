use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    dist_name           => '<tmpl_var distro>',
    dist_abstract       => '',
    dist_author         => '<tmpl_var author> <<tmpl_var email>>',
    license             => '<tmpl_var license>',
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
            '<tmpl_var templatedir>',
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
    add_to_cleanup      => [ '<tmpl_var distro>-*' ],
    create_makefile_pl  => 'traditional',
    sign                => 1,
);

$builder->add_build_element('tmpl');
$builder->create_build_script();

