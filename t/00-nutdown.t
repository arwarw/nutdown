#!/usr/bin/perl

use strict;

use Test::More tests => 31;
use IPC::Run qw(run);

my $nutdown = './script/nutdown';
my $conf = './t/conf';
my $state = './t/state';
my $init = './t/start-nut.sh';

# 1-3
ok(-d $conf, "$conf directory exists");
ok(-x $nutdown, "$nutdown executable exists");
ok(-x $init, "$init executable exists");

# 4-6
ok(run($init), "upsd start");
ok(-d $state, "$state directory exists");
ups_state('OL', 100);
ok(run($nutdown, "--no-syslog", "--configfile", "$conf/nutdown.conf"), "nutdown starts with test config");
sleep 5;

# The test config in nutdown.conf creates files instead of executing the
# typical shutdown/sync/whatever commands since that is easier to test

# 7
ups_state('OB', 100); # on battery
ok(-f "$state/on_battery", "on battery indicator file exists at power failure");

# 8
ups_state('OB', 80);
ok(-f "$state/below_90", "below 90% battery indicator file exists");

# 9
ups_state('OB', 70);
ok(-f "$state/below_75", "below 75% battery indicator file exists");

# 10 - 12
ups_state('OB.LB', 10); # take two steps at once
ok(-f "$state/below_60", "below 60% battery indicator file exists");
ok(-f "$state/below_50", "below 50% battery indicator file exists");
ok(not (-f "$state/below_10"), "below 10% battery indicator file does not yet exist");

# 13
ups_state('OB.LB', 0);
ok(-f "$state/below_10", "below 10% battery indicator file exists");

# 14 - 16
ups_state('OL', 0);
ok(-f "$state/power_return", "power_return indicator present");
ok(not (-f "$state/on_battery"), "on battery no longer indicated on power return");
ok(not (-f "$state/below_10" or -f "$state/below_90"), "below x% indicator files no longer exist");

# 17
ups_state('OL', 50);
ok(not (-f "$state/on_battery"), "on battery no longer indicated on power return");

# 18 - 23
ups_state('OB', 40);
ok(not (-f "$state/power_return"), "power return indicator no longer present");
ok(-f "$state/on_battery", "on battery indicated after repeated power failure");
ok(-f "$state/below_90", "below 90% battery indicator file exists");
ok(-f "$state/below_75", "below 75% battery indicator file exists");
ok(-f "$state/below_60", "below 60% battery indicator file exists");
ok(-f "$state/below_50", "below 50% battery indicator file exists");
# FIXME: check if those files were created in the right order? (i.e. the actions were executed in the right order)

# 24
ok(not (-f "$state/below_10"), "below 10% battery indicator does not exist");

# 25 - 27
ups_state('OL', 79);
ok(-f "$state/power_return", "power_return indicator present");
ok(not (-f "$state/on_battery"), "on battery no longer indicated on power return");
ok(not (-f "$state/below_10" or -f "$state/below_90"), "below x% indicator files no longer exist");
# everything should be alright again, state should be cleaned up.

# 28 - 31
# test power_stable
ups_state('OB', 70);
sleep(3);
ok(not (-f "$state/power_stable"), "power_stable does not exist if on battery");
ups_state('OL', 79);
sleep(6);
ok(not (-f "$state/power_stable"), "power_stable does not exist if on line but below power_stable_time");
ups_state('OL', '80');
sleep(2);
ok(not (-f "$state/power_stable"), "power_stable does not exist if on line but still (2s) below power_stable_time");
sleep(2);
ok(-f "$state/power_stable", "power_stable does exist if power is stable");

# TODO: test FSD, unknown_percentage, unknown_status?

done_testing();
# cleanup
for ((10, 50, 60, 75, 90)) {
	unlink "$state/below_$_";
	unlink "$state/on_battery";
	unlink "$state/power_return";
}

run "pkill", "nutdown";
run "pkill", "upsd";
run "pkill", "dummy-ups";

exit(0);

sub ups_state {
	my $status = shift;
	my $battery = shift;

	my $output = <<EOT;
battery.charge: $battery
battery.voltage: 55.70
battery.voltage.high: 52.00
battery.voltage.low: 41.60
battery.voltage.nominal: 48.0
device.mfr: CABLO
device.model: 3000A
device.type: ups
driver.name: blazer_ser
driver.parameter.pollinterval: 2
driver.parameter.port: /dev/ttyUSB0
driver.version: 2.6.4
driver.version.internal: 1.55
input.current.nominal: 14.0
input.frequency: 50.0
input.frequency.nominal: 50
input.voltage: 232.0
input.voltage.fault: 232.0
input.voltage.nominal: 230
output.voltage: 232.0
ups.beeper.status: disabled
ups.delay.shutdown: 30
ups.delay.start: 180
ups.firmware: 2008 V9.D
ups.load: 4
ups.mfr: CABLO
ups.model: 3000A
ups.status: $status
ups.temperature: 31.0
ups.type: offline / line interactive
EOT
	open DATA, ">", "$conf/dummy-data";
	print DATA $output;
	close DATA;
	sleep 4; # wait 4 times the poll interval for reactions to happen.
}
