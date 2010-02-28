# $Id$

=head1 NAME

Module::Starter::Plugin::CGIApp - template based module starter for CGI apps.

=head1 SYNOPSIS

    use Module::Starter qw(
        Module::Starter::Simple
        Module::Starter::Plugin::Template
        Module::Starter::Plugin::CGIApp
    );

    Module::Starter->create_distro(%args);

=head1 ABSTRACT

This is a plugin for L<Module::Starter> that builds you a skeleton 
L<CGI::Application> module with all the extra files needed to package it for 
CPAN. You can customize the output using L<HTML::Template>.

=cut

package Module::Starter::Plugin::CGIApp;

use warnings;
use strict;
use Carp qw( croak );
use English qw( -no_match_vars );
use ExtUtils::Command qw( mkpath );
use File::Basename;
use File::Spec ();
use Module::Starter::Simple;
use HTML::Template;

=head1 VERSION

Version 0.10

=cut

our $VERSION = '0.10';

=head1 DESCRIPTION

This module subclasses L<Module::Starter::Plugin::Template> which in turn 
subclasses L<Module::Starter::Simple>. This document only describes the methods
which are overriden from those modules or are new.

Only developers looking to extend this module need to read this. If you just 
want to use L<Module::Starter::Plugin::CGIApp>, read the docs for 
L<cgiapp-starter> or L<titanium-starter> instead.

=head1 METHODS

=head2 new ( %args )

This method calls the C<new> supermethod from 
L<Module::Starter::Plugin::Template> and then initializes the template store 
and renderer. (See C<templates> and C<renderer> below.)

=cut

sub new {
    my ( $class, @opts ) = @_;
    my $self = $class->SUPER::new(@opts);

    $self->{templates} = { $self->templates };
    $self->{renderer}  = $self->renderer;
    return bless $self => $class;
}

=head2 create_distro ( %args ) 

This method works as advertised in L<Module::Starter>.

=cut

sub create_distro {
    my ( $class, @opts ) = @_;

    my $self = $class->new(@opts);

    my @modules = map { split /,/msx } @{ $self->{modules} };

    if ( !@modules ) {
        croak "No modules specified.\n";
    }
    for (@modules) {
        if ( !/\A[a-z_]\w*(?:::[\w]+)*\Z/imsx ) {
            croak "Invalid module name: $_";
        }
    }

    if ( !$self->{author} ) {
        croak "Must specify an author\n";
    }
    if ( !$self->{email} ) {
        croak "Must specify an email address\n";
    }
    ( $self->{email_obfuscated} = $self->{email} ) =~ s/@/ at /msx;

    $self->{license} ||= 'perl';

    $self->{main_module} = $self->{modules}->[0];
    if ( !$self->{distro} ) {
        $self->{distro} = $self->{main_module};
        $self->{distro} =~ s/::/-/gmsx;
    }

    $self->{basedir} = $self->{dir} || $self->{distro};
    $self->create_basedir;

    my @distroparts = split /-/msx, $self->{distro};
    $self->{templatedir} =
      File::Spec->catdir( 'lib', @distroparts, 'templates' );

    my @files;
    push @files, $self->create_modules(@modules);

    push @files, $self->create_t(@modules);
    push @files, $self->create_tmpl();
    my %build_results = $self->create_build();
    push @files, @{ $build_results{files} };

    push @files, $self->create_Changes;
    push @files, $self->create_README( $build_results{instructions} );
    push @files, $self->create_MANIFEST_SKIP;
    push @files, $self->create_perlcriticrc;
    push @files, $self->create_server_pl;
    push @files, 'MANIFEST';
    $self->create_MANIFEST( grep { $_ ne 't/boilerplate.t' } @files );

    return;
}

=head2 create_MANIFEST_SKIP( )

This method creates a C<MANIFEST.SKIP> file in the distribution's directory so 
that unneeded files can be skipped from inclusion in the distribution.

=cut

sub create_MANIFEST_SKIP {    ## no critic 'NamingConventions::Capitalization'
    my $self = shift;

    my $fname = File::Spec->catfile( $self->{basedir}, 'MANIFEST.SKIP' );
    $self->create_file( $fname, $self->MANIFEST_SKIP_guts() );
    $self->progress("Created $fname");

    return 'MANIFEST.SKIP';
}

=head2 create_perlcriticrc( )

This method creates a C<perlcriticrc> in the distribution's test directory so 
that the behavior of C<perl-critic.t> can be modified.

=cut

sub create_perlcriticrc {
    my $self = shift;

    my @dirparts = ( $self->{basedir}, 't' );
    my $tdir = File::Spec->catdir(@dirparts);
    if ( not -d $tdir ) {
        local @ARGV = $tdir;
        mkpath();
        $self->progress("Created $tdir");
    }

    my $fname = File::Spec->catfile( @dirparts, 'perlcriticrc' );
    $self->create_file( $fname, $self->perlcriticrc_guts() );
    $self->progress("Created $fname");

    return 't/perlcriticrc';
}

=head2 create_server_pl( )

This method creates C<server.pl> in the distribution's root directory.

=cut

sub create_server_pl {
    my $self = shift;

    my $fname = File::Spec->catfile( $self->{basedir}, 'server.pl' );
    $self->create_file( $fname, $self->server_pl_guts() );
    $self->progress("Created $fname");

    return 'server.pl';
}

=head2 create_t( @modules )

This method creates a bunch of *.t files.  I<@modules> is a list of all modules
in the distribution.

=cut

sub create_t {
    my ( $self, @modules ) = shift;

    my %t_files = $self->t_guts(@modules);

    my @files = map { $self->_create_t( $_, $t_files{$_} ) } keys %t_files;

    # This next part is for the static files dir t/www
    my @dirparts = ( $self->{basedir}, 't', 'www' );
    my $twdir = File::Spec->catdir(@dirparts);
    if ( not -d $twdir ) {
        local @ARGV = $twdir;
        mkpath();
        $self->progress("Created $twdir");
    }
    my $placeholder =
      File::Spec->catfile( @dirparts, 'PUT.STATIC.CONTENT.HERE' );
    $self->create_file( $placeholder, q{ } );
    $self->progress("Created $placeholder");
    push @files, 't/www/PUT.STATIC.CONTENT.HERE';

    return @files;
}

=head2 create_tmpl( )

This method takes all the template files ending in .html (representing 
L<HTML::Template>'s and installs them into a directory under the distro tree.  
For instance if the distro was called C<Foo-Bar>, the templates would be 
installed in C<lib/Foo/Bar/templates>.

Note the files will just be copied over not rendered.

=cut

sub create_tmpl {
    my $self = shift;

    return $self->tmpl_guts();
}

=head2 render( $template, \%options )

This method is subclassed from L<Module::Starter::Plugin::Template>.

It is given an L<HTML::Template> and options and returns the resulting document.

Data in the C<Module::Starter> object which represents a reference to an array 
@foo is transformed into an array of hashes with one key called 
C<$foo_item> in order to make it usable in an L<HTML::Template> C<TMPL_LOOP>.
For example:

    $data = ['a'. 'b', 'c'];

would become:

    $data = [
        { data_item => 'a' },
        { data_item => 'b' },
        { data_item => 'c' },
    ];
    
so that in the template you could say:

    <tmpl_loop data>
        <tmpl_var data_item>
    </tmpl_loop>
    
=cut

sub render {
    my ( $self, $template, $options ) = @_;

    # we need a local copy of $options otherwise we get recursion in loops
    # because of [1]
    my %opts = %{$options};

    $opts{nummodules}    = scalar @{ $self->{modules} };
    $opts{year}          = $self->_thisyear();
    $opts{license_blurb} = $self->_license_blurb();
    $opts{datetime}      = scalar localtime;

    foreach my $key ( keys %{$self} ) {
        next if defined $opts{$key};
        $opts{$key} = $self->{$key};
    }

    # [1] HTML::Templates wants loops to be arrays of hashes not plain arrays
    foreach my $key ( keys %opts ) {
        if ( ref $opts{$key} eq 'ARRAY' ) {
            my @temp = ();
            for my $option ( @{ $opts{$key} } ) {
                push @temp, { "${key}_item" => $option };
            }
            $opts{$key} = [@temp];
        }
    }
    my $t = HTML::Template->new(
        die_on_bad_params => 0,
        scalarref         => \$template,
    ) or croak "Can't create template $template";
    $t->param( \%opts );
    return $t->output;
}

=head2 renderer ( )

This method is subclassed from L<Module::Starter::Plugin::Template> but
doesn't do anything as the actual template is created by C<render> in this 
implementation.

=cut

sub renderer {
    my ($self) = @_;
    return;
}

=head2 templates ( )

This method is subclassed from L<Module::Starter::Plugin::Template>.

It reads in the template files and populates the object's templates 
attribute. The module template directory is found by checking the 
C<MODULE_TEMPLATE_DIR> environment variable and then the config option 
C<template_dir>.

=cut

sub templates {
    my ($self) = @_;
    my %template;

    my $template_dir = ( $ENV{MODULE_TEMPLATE_DIR} || $self->{template_dir} )
      or croak 'template dir not defined';
    if ( !-d $template_dir ) {
        croak "template dir does not exist: $template_dir";
    }

    foreach ( glob "$template_dir/*" ) {
        my $basename = basename $_;
        next if ( not -f $_ ) or ( $basename =~ /\A \./msx );
        open my $template_file, '<', $_
          or croak "couldn't open template: $_";
        $template{$basename} = do {
            local $RS = undef;
            <$template_file>;
        };
        close $template_file or croak "couldn't close template: $_";
    }

    return %template;
}

=head2 Changes_guts

Implements the creation of a C<Changes> file.

=cut

sub Changes_guts {    ## no critic 'NamingConventions::Capitalization'
    my $self = shift;
    my %options;

    my $template = $self->{templates}{Changes};
    return $self->render( $template, \%options );
}

=head2 MANIFEST_SKIP_guts

Implements the creation of a C<MANIFEST.SKIP> file.

=cut

sub MANIFEST_SKIP_guts {    ## no critic 'NamingConventions::Capitalization'
    my $self = shift;
    my %options;

    my $template = $self->{templates}{'MANIFEST.SKIP'};
    return $self->render( $template, \%options );
}

=head2 perlcriticrc_guts

Implements the creation of a C<perlcriticrc> file.
 
=cut

sub perlcriticrc_guts {
    my $self = shift;
    my %options;

    my $template = $self->{templates}{perlcriticrc};
    return $self->render( $template, \%options );
}

=head2 server_pl_guts

Implements the creation of a C<server.pl> file.

=cut

sub server_pl_guts {
    my $self = shift;
    my %options;
    $options{main_module} = $self->{main_module};

    my $template = $self->{templates}{'server.pl'};
    return $self->render( $template, \%options );
}

=head2 t_guts

Implements the creation of test files.

=cut

sub t_guts {
    my ( $self, @opts ) = @_;
    my %options;
    $options{modules}     = [@opts];
    $options{modulenames} = [];
    foreach ( @{ $options{modules} } ) {
        push @{ $options{module_pm_files} }, $self->_module_to_pm_file($_);
    }

    my %t_files;

    foreach ( grep { /\.t\z/msx } keys %{ $self->{templates} } ) {
        my $template = $self->{templates}{$_};
        $t_files{$_} = $self->render( $template, \%options );
    }

    return %t_files;
}

=head2 tmpl_guts

Implements the creation of template files.

=cut

sub tmpl_guts {
    my ($self) = @_;
    my %options;    # unused in this function.

    # we need the directory seperator to be / regardless of OS
    my $reldir = join q{/}, File::Spec->splitdir( $self->{templatedir} );
    my @dirparts = ( $self->{basedir}, $self->{templatedir} );
    my $tdir = File::Spec->catdir(@dirparts);
    if ( not -d $tdir ) {
        local @ARGV = $tdir;
        mkpath();
        $self->progress("Created $tdir");
    }

    my @t_files;
    foreach my $filename ( grep { /\.html\z/msx } keys %{ $self->{templates} } )
    {
        my $template = $self->{templates}{$filename};
        my $fname = File::Spec->catfile( @dirparts, $filename );
        $self->create_file( $fname, $template );
        $self->progress("Created $fname");
        push @t_files, "$reldir/$filename";
    }

    return @t_files;
}

=head1 BUGS

Please report any bugs or feature requests to 
C<bug-module-starter-plugin-cgiapp at rt.cpan.org>, or through the web 
interface at L<http://rt.cpan.org>. I will be notified, and then you'll 
automatically be notified of progress on your bug as I make changes.

=head1 AUTHOR

Jaldhar H. Vyas, E<lt>jaldhar at braincells.comE<gt>

=head1 COPYRIGHT

Copyright (C) 2008,  Consolidated Braincells Inc. All Rights Reserved.

This distribution is free software; you can redistribute it and/or modify it
under the terms of either:

a) the GNU General Public License as published by the Free Software
Foundation; either version 2, or (at your option) any later version, or

b) the Artistic License version 2.0.

The full text of the license can be found in the LICENSE file included
with this distribution.

=head1 SEE ALSO

L<cgiapp-starter>, L<titanium-starter>, L<Module::Starter>, 
L<Module::Starter::Simple>, L<Module::Starter::Plugin::Template>. 
L<CGI::Application>, L<Titanium>, L<HTML::Template>

=cut

1;

