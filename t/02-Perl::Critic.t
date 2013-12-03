#!/usr/bin/perl

use Test::Perl::Critic;
use Test::More tests => 1;

critic_ok('script/nutdown');
