#
# $Id$
#
use strict;
use warnings;
use File::Find;
use Module::Build;

my $subclass = Module::Build->subclass(code => <<'EOT');
sub _find_pods {
    my ($self, $dirs, %args) = @_;

    my $files = $self->SUPER::_find_pods($dirs, %args);

    foreach (grep { m{^blib/lib/Module/Starter/Plugin/CGIApp/templates}; } keys %{$files} ) {
        delete $files->{$_};
    }
    
    return $files;
}

sub find_PL_files {
    my $self = shift;

    my $out = $self->SUPER::find_PL_files;

    foreach (grep { m{^lib/Module/Starter/Plugin/CGIApp/templates}; } keys %{$out} ) {
        delete $out->{$_};
    }
    
    return $out;
}
EOT

my $builder = $subclass->new(
    module_name         => 'Module::Starter::Plugin::CGIApp',
    license             => 'perl',
    dist_author         => 'Jaldhar H. Vyas <jaldhar@braincells.com>',
    dist_version        => '0.20',
    pm_files            => {
        'lib/Module/Starter/Plugin/CGIApp.pm' => 'lib/Module/Starter/Plugin/CGIApp.pm',
    },
    PL_files            => {
        'lib/Module/Starter/Plugin/CGIApp/templates/Makefile.PL' => [],
        'lib/Module/Starter/Plugin/CGIApp/templates/titanium/Makefile.PL' => [],
    },
    script_files            => {
        'script/cgiapp-starter' => [],
        'script/titanium-starter' => [],
    },
    tmpl_files          => eval { 
        my %tmpls; File::Find::find(
            {
                wanted => sub {
                    if ( -f $_ ) {
                        $tmpls{$File::Find::name} = $File::Find::name;
                    }
                },
            }, 
            'lib/Module/Starter/Plugin/CGIApp/templates/',
        );
        return \%tmpls;
    },
    build_requires      => {
        'Module::Signature'     => 0,
        'Test::More'            => 0,
    },
    requires            => {
        'ExtUtils::Command'     => 0,
        'File::Basename'        => 0,
        'File::Spec'            => 0,
        'Module::Starter'       => 0,
        'HTML::Template'        => 0,
    },
    add_to_cleanup      => [ 'Module-Starter-Plugin-CGIApp-*' ],
    create_makefile_pl  => 'traditional',
    sign                => 1,
);

$builder->add_build_element('tmpl');
$builder->create_build_script();

