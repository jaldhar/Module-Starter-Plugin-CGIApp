use inc::Module::Install;

name     'Foo';
all_from 'lib/Foo.pm';
author   'Jaldhar H. Vyas';

build_requires 'Test::More'                    => 0;
build_requires 'Test::WWW::Mechanize::CGIApp'  => 0;
requires       'CGI::Application'              => 4.04;
requires       'HTML::Template'                => 0;
auto_install;
sign 1;

WriteAll;

