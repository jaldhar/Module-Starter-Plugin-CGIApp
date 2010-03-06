use inc::Module::Install;

name         '<tmpl_var distro>';
abstract     'Abstract goes here.';
author       '<tmpl_var author>';
license      '<tmpl_var license>';
version      '0.01';
perl_version '5.008';

build_requires 'Test::More'                    => 0;
build_requires 'Test::WWW::Mechanize::CGIApp'  => 0;
requires       'CGI::Application'              => 4.04;
requires       'HTML::Template'                => 0;
auto_install;
sign 1;

WriteAll;

