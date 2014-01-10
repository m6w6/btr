# btr

A poor man's CI tool.

## BUILD TEST REPORT

A simple tool to automate reporting of build and test results.

### Currently supported rulesets:

* ***source:*** git, svn, cvs
* ***build:*** php, pecl, gnu, composer
* ***report:*** mail, notify-send, twilio, irc

#### Usage
```
Usage: btr [-hyvqcC] [<options>]

    -h, --help      Display this help
    -y, --yes       Always assume yes
    -v, --verbose   Be more verbose
    -q, --quiet     Be more quiet
    -c, --clean     Clean build
    -C, --vcsclean  Clean repo/branch

  Options:
    -f, --config=<file>           Read configuration from a file
    -s, --source=<rules>          Use the specified source ruleset
    -b, --build=<rules>           Use the specified build ruleset
    -r, --report=<rules>          Use the specifued report ruleset
    -T, --test=<args>             Provide test runner arguments
    -B, --branch=<branch>         Checkout this branch
    -D, --directory=<directory>   Use this directory as work root
    -S, --suffix=<suffix>         Append suffix to the build name

  Rules format:
    type=argument    e.g: git=git@github.com:m6w6/btr.git
                          irc=irc://btr@chat.freenode.org/#btr
                          mail="-c copy@to rcpt@to"
                          notify-send="-u low"

    Note though, that some rules do not use any argument.

  Rulesets:
        source: cvs git svn
         build: composer gnu pecl php
        report: irc mail notify-send twilio

  Examples:

  Clone PHP's git, use PHP-5.5 branch, build with php ruleset and
  run the test suite with valgrind (-m) on a debug build and report
  the results with a simple OSD notification:
    $ btr -s git=git@php.net:php/php-src.git -B PHP-5.5 \
          -b "php=--enable-debug" -T-m -r notify-send
  See also php.example.conf

  Clone CURL's git (use master), build with GNU autotools
  ruleset which runs 'make check' and mail the report to the
  current user. Verbosely show all actions taken:
    $ btr -v -s git=https://github.com/bagder/curl.git -b gnu -r mail
  See also curl.example.conf

```
