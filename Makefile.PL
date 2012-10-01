use inc::Module::Install;
name 'EkiDataJp';
all_from 'lib/EkiDataJp.pm';
readme_markdown_from 'lib/EkiDataJp.pm';
githubmeta;

# requires '';

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
