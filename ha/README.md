# Solace AMI HA Scripts

This project contains basic scripts to generate and execute CLI scripts for faster setup of 
Solace PubSub+ software event brokers on AWS AMI nodes.
AMI nodes can't take advantage of cloud-init keys for pre-configuring the event broker before booting the first time. So AMI users have to go through several extra steps that can involve reboots of the event broker that are not necessary in other deployments.

## Assumptions

These scripts ASSUME that the nodes have already been setup. Lesser 
assumption is that the PubSub+ event broker is a docker container named 'solace'.
You can easily change that assumption by modifying the `install_cliscripts.sh` script.

## Steps

The project must be copied out to ALL THREE MEMBRERS of the HA group.

### 1. Edit the `env.sh` environment variables to match your environment. 
_SET THE ROLE VARIABLE APPRORIATELY FOR EACH NODE_; then set the IP-address.
In AWS, that typically means public IPs and private IPs. Your redundancy 
may need to be configured with private IPs or public IPs.

You control that in the `DERIVED VARIABLES` section where the variables
[ `primary_ip, backup_ip, monitor_ip` ] are controlled.

### 2. Apply those environment variables to the script templates:

`./apply_env_to_clis.sh`

This creates real CLI scripts based on templates with your env-vars substituted.

```bash
0_init_monitor.cli
0_init_scale.cli
1_setup_redundancy.cli
2_post_redundancy_msging.cli
3_primary_cfgsync_assert.cli
```

### 3. Install the scripts scripts into your PubSub+ event broker containers `cliscripts/` directory.

`./install_cliscripts.sh`

### 4. Reboot each node to default settings:

PRIMARY CLI: `reload default-config`

BACKUP  CLI: `reload default-config`

MONITOR CLI: `reload default-config monitoring-node`

### 5. Execute all of these steps at CLI prompts on each node.

#### 5.1. Run the initialization script appropriate to each node:

PRIMARY CLI: `source script cliscripts/0_init_scale.cli stop-on-error no-prompt`

BACKUP  CLI: `source script cliscripts/0_init_scale.cli stop-on-error no-prompt`

MONITOR CLI: `source script cliscripts/0_init_monitor.cli stop-on-error no-prompt`

Again, this forces a reload. Wait until the node CLI is available to continue.
Then verify that scaling mode is 1000 connections:

```CLI
ip-172-31-11-158> show system

System Uptime: 0d 0h 27m 47s
Last Restart Reason: User request

Available Resources:
   CPU cores: 2
   System Memory: 8.0 GiBytes
Scaling:
   Max Connections: 1000
Topic Routing:
   Subscription Exceptions: Enabled
   Subscription Exceptions Defer: Enabled
```

#### 5.2. Run the HA Redundancy setup script appropriate to each node:

PRIMARY CLI: `source script cliscripts/1_setup_redundancy.cli stop-on-error no-prompt`

BACKUP  CLI: `source script cliscripts/1_setup_redundancy.cli stop-on-error no-prompt`

MONITOR CLI: `source script cliscripts/1_setup_redundancy.cli stop-on-error no-prompt`

#### 5.3. Run the script to re-enable persistent messaging WITH HA:

PRIMARY CLI: `source script cliscripts/2_post_redundancy_msging.cli stop-on-error no-prompt`

BACKUP  CLI: `source script cliscripts/2_post_redundancy_msging.cli stop-on-error no-prompt`

#### 5.4. On the PRIMARY node ONLY, you will need to assert ownership of config-sync channels:

PRIMARY CLI: `source script cliscripts/3_primary_cfgsync_assert.cli stop-on-error no-prompt`

### 6. Checking everything:

CLI commands to validate correct operations:

```CLI
ip-172-31-11-158> show service

Msg-Backbone:       Enabled
  VRF:              management
  SMF:              Enabled
    Web-Transport:  Enabled
```

```CLI
ip-172-31-11-158> show redundancy
Configuration Status     : Enabled
Redundancy Status        : Up
Operating Mode           : Message Routing Node
Switchover Mechanism     : Hostlist
Auto Revert              : No
Redundancy Mode          : Active/Standby
Active-Standby Role      : Backup
Mate Router Name         : dtcc-primary
ADB Link To Mate         : Up
ADB Hello To Mate        : Up
```

```CLI
ip-172-31-11-158> show redundancy group
Node Router-Name   Node Type       Address           Status
-----------------  --------------  ----------------  ---------
dtcc-backup*       Message-Router  172.31.11.158     Online
dtcc-monitor       Monitor         172.31.9.89       Online
dtcc-primary       Message-Router  172.31.15.159     Online

* - indicates the current node
```
ip-172-31-15-159> show config-sync

Admin Status                      : Enabled
Oper Status                       : Up
SSL Enabled                       : No
Authentication
...
```
