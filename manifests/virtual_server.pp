# Define : keepalived::virtual_server
#
# Define a virtual server. 
#
# Parameters :
#        state : MASTER or BACKUP
#        virtual_router_id
#        virtual_ipaddress
#        virtual_server_port
#        lb_kind = 'DR' : Support only DR in this version
#	 lb_algo = 'wlc
#        interface = 'eth0'
#        priority = '' : If not set, BACKUP will take 100 and MASTER 200

define keepalived::virtual_server ( 
	$state, 
	$virtual_router_id, 
	$virtual_ipaddress,
	$virtual_server_port,
	$lb_kind = 'DR',
	$lb_algo = 'wlc',
	$lb_passwd = 'changeme',
	$interface = 'eth0',
	$priority = '' ) {

	#Variables manipulations
	$real_priority = $priority ? {
		'' => $state ? {
			'MASTER' => '200',
			'BACKUP' => '100',
		      },
		default => $priority,
	}

	#Generate a fixed-random password for this virtual server
	$auth_pass = $lb_passwd

	#Construct /etc/keepalived/keepalived.conf
        file {"/etc/keepalived/conf.d/virtual_${name}.conf":
            content => template("keepalived/virtual_server.erb"),
            mode => 0644,
            owner => root,
            group => 0,
			notify => Exec["reload-keepalived"],
        }

        file {"/etc/keepalived/vrrp_backup.sh":
            content => template("keepalived/vrrp_backup.sh.erb"),
            mode => 0644,
            owner => root,
            group => 0,
			notify => Exec["reload-keepalived"],
        }

        file {"/etc/keepalived/vrrp_master.sh":
            content => template("keepalived/vrrp_master.sh.erb"),
            mode => 0644,
            owner => root,
            group => 0,
			notify => Exec["reload-keepalived"],
        }

		file { "/etc/keepalived/vrrp_status.sh":  
			ensure => "file",
			owner  => "root",
			mode   => "0644",
			source => "puppet:///modules/keepalived/etc/keepalived/vrrp_status.sh",
		}
	# Configure DSR on real servers with exported ressources
	# Be carefull when server reboots

	if $state == "MASTER" { #Export only when MASTER
		exec{"add-loopback-DSR-$virtual_ipaddress":
			command => "/sbin/ip addr add ${virtual_ipaddress}/32 dev lo",
			onlyif => "/usr/bin/test -z \"`/sbin/ip addr ls lo | grep ${virtual_ipaddress}/32`\"",
			tag => "keepalived-exported-dsr-config-$name",
		}
		exec{"add-arp_announce-config-DSR-$name":
			command => "/sbin/sysctl net.ipv4.conf.all.arp_announce=2",
			onlyif => "/usr/bin/test -z \"`/sbin/sysctl net.ipv4.conf.all.arp_announce | grep 2`\"",
			tag => "keepalived-exported-dsr-config-$name",
		}
		exec{"add-arp_ignore-config-DSR-$name":
			command => "/sbin/sysctl net.ipv4.conf.all.arp_ignore=1",
			onlyif => "/usr/bin/test -z \"`/sbin/sysctl net.ipv4.conf.all.arp_ignore | grep 1`\"",
			tag => "keepalived-exported-dsr-config-$name",
		}
	}
 
}
