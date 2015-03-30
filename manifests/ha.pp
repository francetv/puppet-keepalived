define keepalived::ha (
	$vip = [],
	$lb_passwd = 'changeme',
	$interface = 'eth0',
	$type = 'haproxy'
) {

	#Generate a fixed-random password for this virtual server
	$auth_pass = $lb_passwd

	file {"/etc/keepalived/conf.d/vrrp_instance.conf":
		content => template("keepalived/vrrp_instance.erb"),
		mode => 0644,
		owner => root,
		group => 0,
		notify => Exec["reload-keepalived"],
	}

	augeas{'tcp tunning':
		context => "/files/etc/sysctl.conf",
		changes => [
			"set net.ipv4.conf.all.arp_announce	2",
			"set net.ipv4.conf.all.arp_ignore		1",
			"set net.ipv4.ip_nonlocal_bind			1",
		],
		notify => Exec["sysctl"]
	}

	file { "sysctl_conf":
		name => $operatingsystem ? {
			default => "/etc/sysctl.conf",
		},
	}

	exec { "/sbin/sysctl -p":
		alias => "sysctl",
		refreshonly => true,
		subscribe => File["sysctl_conf"],
	}
}
