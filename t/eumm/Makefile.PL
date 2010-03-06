use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Example-Dist',
    ABSTRACT            => '',
    AUTHOR              => 'Jaldhar H. Vyas <jaldhar@braincells.com>',
    LICENSE             => 'perl',
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
    clean               => { FILES => 'Example-Dist-*' },
);
