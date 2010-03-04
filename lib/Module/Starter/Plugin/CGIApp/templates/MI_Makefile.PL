use inc::Module::Install;

name     '<tmpl_var distro>';
all_from '<tmpl_var main_pm_file>';
author   '<tmpl_var author>';

build_requires 'Test::More'                    => 0;
build_requires 'Test::WWW::Mechanize::CGIApp'  => 0;
requires       'CGI::Application'              => 4.04;
requires       'HTML::Template'                => 0;
auto_install;
sign 1;

WriteAll;

