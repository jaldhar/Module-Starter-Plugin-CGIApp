use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => '<tmpl_var distro>',
    ABSTRACT            => '',
    AUTHOR              => '<tmpl_var author> <<tmpl_var email>>',
    LICENSE             => '<tmpl_var license>',
    VERSION             => '0.01',
    PL_FILES            => {},
    PREREQ_PM => {
        'CGI::Application'              => 4.04,
        'HTML::Template'                => 0,
        'Test::More'                    => 0,
        'Test::WWW::Mechanize::CGIApp'  => 0,
    },
    SIGN => 1,
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => '<tmpl_var distro>-*' },
);
