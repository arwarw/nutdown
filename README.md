# nutdown
NUT UPS configurable shutdown daemon

## Description
nutdown connects to a NUT server, listening for power failures, other UPS-related events as well as battery charge percentages.

You can then define actions for hosts or groups of hosts such as "shut this host down at 90% remaining", "kill that group via SysRq at 20% remaining", etc.
This means that your important infrastructure can remain on UPS power longer, since the unimportant parts were already shut down early.
You can also avoid problems like "this NFS client doesn't shut down because the NFS server is already gone" by properly planing and
executing an emergency shutdown.
