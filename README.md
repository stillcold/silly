# x(forked from https://github.com/findstr/silly, but so many changes have been made)

[![license](https://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat)](https://github.com/findstr/silly/blob/master/LICENSE)

--------

## Depend

- sudo apt-get install libreadline-dev(debain)
- yum install readline-devel(centos)

## Build

- make linux
- make macosx

## Run
    ./x <configfile>

## Config

- daemon, 1 --> run as daemon, 0 --> normal
- bootstrap, lua entry file
- lualib_path, will append the package.path (in luaVM)
- lualib_cpath, will append the package.cpath (int luaVM)
- logpath, when run as daemon, all print message will write to [logpath]/silly-[pid].log file
- pidfile, when run as daemon, 'pidfile' will used by run only once on a system

## Test

- all the test code will be included into ./test folder
- run ./silly test/test will auto test all module


