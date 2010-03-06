use inc::Module::Install;

name         'Example-Dist';
abstract     '';
author       'Jaldhar H. Vyas';
license      'perl';
version      '0.01';
perl_version '5.008';

build_requires 'Test::More'                    => 0;
build_requires 'Test::WWW::Mechanize::CGIApp'  => 0;
requires       'CGI::Application'              => 4.04;
requires       'HTML::Template'                => 0;
auto_install;
sign 1;

WriteAll;

