#!/usr/bin/perl

use strict;
use warnings;
use inc::Module::Install;

name 'nutdown';
all_from 'script/nutdown';

install_script 'script/nutdown';

WriteAll;
