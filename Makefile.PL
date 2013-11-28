#!/usr/bin/perl

use strict;
use warnings;
use inc::Module::Install;

name 'nutdown';
all_from 'script/nutdown';

requires 'Sys::Syslog';
requires 'Sys::Hostname';
requires 'Config::General';
requires 'UPS::Nut';
requires 'IPC::Run';
requires 'Data::Dumper';
requires 'Getopt::Long';
requires 'Pod::Usage';

test_requires 'Test::More';

install_script 'script/nutdown';

postamble <<'END_OF_MAKEFILE';
install:: extra_install
pure_install:: extra_install
install_vendor:: extra_install

extra_install:
	install -d $(DESTDIR)/etc/
	install -d $(DESTDIR)/etc/nutdown
END_OF_MAKEFILE

WriteAll;
