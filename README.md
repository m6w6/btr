# btr

## BUILD TEST REPORT

A simple tool to automate reporting of build and test results.

### Currently supported rulesets:

* source: git, svn
* build: php, pecl
* report: mail

#### Usage
```
Usage: btr [-hv] [<options>] <repository>

    -h, --help      Display this help
    -v, --verbose   Be more verbose

  Options:
    -s, --source=<rules>          Use the specified source ruleset
    -b, --build=<rules>           Use the specified build ruleset
    -r, --report=<rules>          Use the specifued report ruleset
    -B, --branch=<branch>         Checkout this branch
    -D, --directory=<directory>   Use this directory as work root
    -S, --suffix=<suffix>         Append suffix to the build name
    -C, --configure=<options>     Define $CONFIGURE options

  Rulesets:
    source: git
    build:  php
    report: mail
```
#### Examples

`USER=mike@php.net ./bin/btr -s svn -b pecl -r mail -v https://svn.php.net/repository/pecl/http -B branches/DEV_2`

`USER=mike@php.net TESTS=tests/output ./bin/btr -s git -b php -r mail git@git.php.net:php-src.git`

