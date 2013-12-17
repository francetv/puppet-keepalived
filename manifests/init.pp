# Class: keepalived
#
# This class manage keepalived server installation and configuration. 
#
class keepalived {

    if $enable_notification_email == "" {
        $enable_notification_email = false
    }

	package { keepalived: ensure => installed }
	package { ["ipvsadm", "garp"]: }

	service { keepalived:
		ensure => running,
		enable => true,
		require => Package["keepalived"],
	}

	exec{"reload-keepalived":
		command => "/etc/init.d/keepalived reload",
        refreshonly => true,
    }

	file{"/etc/keepalived/keepalived.conf":
		ensure => present,
		content => template("keepalived/etc/keepalived/keepalived.conf.erb"),
		notify => Service["keepalived"],
	}

	file{"/etc/keepalived/conf.d": ensure => directory}

	file{"/etc/keepalived/conf.d/real_${name}.conf":
		ensure => present,
		content => template("keepalived/real_server.erb"),
		notify => Exec["reload-keepalived"],
		require => File["/etc/keepalived/conf.d"]
	}
}
