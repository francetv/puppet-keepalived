define keepalived::vrrp_instance ( 
	$vip = [],
	$lb_passwd = 'changeme',
	$interface = 'eth0') {

	#Generate a fixed-random password for this virtual server
	$auth_pass = $lb_passwd
	$check_type = 'TCP_CHECK'

    file {"/etc/keepalived/conf.d/vrrp_instance.conf":
        content => template("keepalived/vrrp_instance.erb"),
        mode => 0644,
        owner => root,
        group => 0,
        notify => Exec["reload-keepalived"],
    }

	# Configure DSR on real servers with exported ressources
	# Be carefull when server reboots

	$vip.foreach { |$value|
		if $value['state'] == "MASTER" { #Export only when MASTER
			exec{"add-loopback-DSR-${value['vip']}":
				command => "/sbin/ip addr add ${value[1]}/32 dev lo",
				onlyif => "/usr/bin/test -z \"`/sbin/ip addr ls lo | grep ${value['vip']}/32`\"",
			}
			exec{"add-arp_announce-config-DSR-${value['vip']}":
				command => "/sbin/sysctl net.ipv4.conf.all.arp_announce=2",
				onlyif => "/usr/bin/test -z \"`/sbin/sysctl net.ipv4.conf.all.arp_announce | grep 2`\"",
			}
			exec{"add-arp_ignore-config-DSR-${value['vip']}":
				command => "/sbin/sysctl net.ipv4.conf.all.arp_ignore=1",
				onlyif => "/usr/bin/test -z \"`/sbin/sysctl net.ipv4.conf.all.arp_ignore | grep 1`\"",
			}
		}
	}
}