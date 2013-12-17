# Class: keepalived::server
#
# This class manage keepalived server installation and configuration. 
#
class keepalived::server {

	package { keepalived: ensure => installed }

	service { keepalived:
		ensure => running,
		enable => true,
		require => Package["keepalived"],
	}

	exec{"reload-keepalived":
		command => "/etc/init.d/keepalived reload",
        refreshonly => true,
    }

	file{"/etc/keepalived/conf.d": ensure => directory}
}
