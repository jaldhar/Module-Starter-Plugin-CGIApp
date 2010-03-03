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
    # Reminder: also change in Makefile.PL
    dist_version        => '0.21',
    pm_files            => {
        'lib/Module/Starter/Plugin/CGIApp.pm' => 'lib/Module/Starter/Plugin/CGIApp.pm',
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
        'File::Copy::Recursive' => 0,
        'File::DirCompare'      => 0,
        'Test::More'            => 0,
        'Test::MockTime'        => 0,
        'Time::Piece'           => 1.12,
    },
    requires            => {
        'perl'                  => 5.008,
        'Module::Starter'       => 0,
        'HTML::Template'        => 0,
    },
    meta_merge => {
        resources => {
            repository  => 'http://github.com/jaldhar/Module-Starter-Plugin-CGIApp',
            homepage    => 'http://jaldhar.github.com/Module-Starter-Plugin-CGIApp/',
        },
    },
    add_to_cleanup      => [ 'Module-Starter-Plugin-CGIApp-*' ],
    create_makefile_pl  => 'small',
    sign                => 1,
);

$builder->add_build_element('tmpl');
$builder->create_build_script();

