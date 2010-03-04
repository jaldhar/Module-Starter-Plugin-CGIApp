use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Foo',
    AUTHOR              => 'Jaldhar H. Vyas <jaldhar@braincells.com>',
    VERSION_FROM        => 'lib/Foo.pm',
    ABSTRACT_FROM       => 'lib/Foo.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'CGI::Application'              => 4.04,
        'HTML::Template'                => 0,
        'Test::More'                    => 0,
        'Test::WWW::Mechanize::CGIApp'  => 0,
    },
    SIGN => 1,
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Foo-*' },
);
