#
# $Id$
#
use strict;
use warnings;
use File::Find;
use Module::Build;

my $subclass = Module::Build->subclass(code => <<'EOT');
sub manify_lib_pods {
    my $self    = shift;

    my $files   = $self->_find_pods($self->{properties}{libdoc_dirs});
    return unless keys %$files;

    my $mandir = File::Spec->catdir( $self->blib, 'libdoc' );
    File::Path::mkpath( $mandir, 0, oct(777) );

    require Pod::Man;
    my $file = 'lib/Module/Starter/Plugin/CGIApp.pm';
    my $relfile = 'Module/Starter/Plugin/CGIApp.pm';
    # Pod::Simple based parsers only support one document per instance.
    # This is expected to change in a future version (Pod::Simple > 3.03).
    # libraries go in section 3
    my $parser  = Pod::Man->new( section => '3pm' );
    my $manpage = $self->man3page_name( $relfile ) . '.' .
        $self->config( 'man3ext' );
    my $outfile = File::Spec->catfile( $mandir, $manpage);
    next if $self->up_to_date( $file, $outfile );
    $self->log_info("Manifying $file -> $outfile\n");
    $parser->parse_from_file( $file, $outfile );
    $files->{$file} = $outfile;
}
EOT

my $builder = $subclass->new(
    module_name         => 'Module::Starter::Plugin::CGIApp',
    license             => 'perl',
    dist_author         => 'Jaldhar H. Vyas <jaldhar@braincells.com>',
    dist_version_from   => 'lib/Module/Starter/Plugin/CGIApp.pm',
    pm_files            => {
        'lib/Module/Starter/Plugin/CGIApp.pm' => 'lib/Module/Starter/Plugin/CGIApp.pm',
    },
    PL_files            => {
        'lib/Module/Starter/Plugin/CGIApp/templates/Makefile.PL' => [],
    },
    script_files            => {
        'script/cgiapp-starter' => [],
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
        'ExtUtils::Command'     => 0,
        'File::Spec'            => 0,
        'Module::Signature'     => 0,
        'Pod::Coverage'         => 0.18,
        'Pod::Usage'            => 0,
        'Test::Builder'         => 0,
        'Test::More'            => 0,
        'Test::Pod'             => 1.22,
        'Test::Pod::Coverage'   => 1.08,
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

