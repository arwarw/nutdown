#!/usr/bin/perl

use strict;
use Test::More tests => 18;
use Data::Dumper qw(Dumper);
use IPC::Run qw(run);

my $nutdown = './nutdown';
my $config = './t/conf/nutdown.conf';

my $output;
my $VAR1;
# 1-2
ok(run([$nutdown, '--configfile', $config, '--hostname', 'testhost1', '--dump-config'], '>', \$output), "dump-config does something");
like($output, qr/ups/, "output contains something about an ups");

eval $output; # sets $var1
# 3-6
ok((exists $VAR1->{ups}) and (exists $VAR1->{event}), "configuration contains ups and event sections");
is_deeply($VAR1->{ups}, { 'password' => 'testpassword', 'timeout' => '30', 'name' => 'testups', 'port' => '63493', 'host' => 'localhost', 'username' => 'testuser' }, "ups section contains what we expect");
is($VAR1->{poll_interval}, 1, "poll_interval default of 30 has been overridden to 1");
is_deeply($VAR1->{event}->{10}, {'syslog' => 'at 10 percent', 'exec' => 'touch t/state/below_10'}, "10 percent event looks like it came from the default entry");

# host examplehost1 overrides those things
# 7 - 10
ok(run([$nutdown, '--configfile', $config, '--hostname', 'examplehost1', '--dump-config'], '>', \$output), "dump-config does something");
eval $output;
is_deeply($VAR1->{ups}, { 'password' => 'testpassword', 'timeout' => '30', 'name' => 'testups', 'port' => '63493', 'host' => 'localhost', 'username' => 'exampleuser1' }, "ups section contains what we expect for examplehost1");
is($VAR1->{poll_interval}, 23, "poll_interval default of 30 has been overridden to 23 for examplehost1");
is_deeply($VAR1->{event}->{10}, {'syslog' => 'hello from examplehost1', 'exec' => '/bin/true'}, "10 percent event looks like it came from examplehost1");


# host examplehost2 sets a group which overrides things
# 11 - 14
ok(run([$nutdown, '--configfile', $config, '--hostname', 'examplehost2', '--dump-config'], '>', \$output), "dump-config does something");
eval $output;
is_deeply($VAR1->{ups}, { 'password' => 'grouppassword', 'timeout' => '30', 'name' => 'testups', 'port' => '63493', 'host' => 'localhost', 'username' => 'examplegroup' }, "ups section contains what we expect for examplehost2");
is($VAR1->{poll_interval}, 42, "poll_interval default of 30 has been overridden to 42 for examplehost2");
is_deeply($VAR1->{event}->{10}, {'syslog' => 'hello from examplegroup', 'exec' => 'touch t/state/below_10'}, "10 percent event looks like it came from examplehost2");

# host examplehost3 sets a group and overrides more things in its host config
# 15 - 18
ok(run([$nutdown, '--configfile', $config, '--hostname', 'examplehost3', '--dump-config'], '>', \$output), "dump-config does something");
eval $output;
is_deeply($VAR1->{ups}, { 'password' => 'grouppassword', 'timeout' => '30', 'name' => 'testups', 'port' => '63493', 'host' => 'localhost', 'username' => 'exampleuser3' }, "ups section contains what we expect for examplehost3");
is($VAR1->{poll_interval}, 42, "poll_interval default of 30 has been overridden to 42 for examplehost3");
is_deeply($VAR1->{event}->{10}, {'syslog' => 'hello from examplehost3', 'exec' => 'touch t/state/below_10'}, "10 percent event looks like it came from examplehost3");

done_testing();
