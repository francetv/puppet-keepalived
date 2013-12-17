# Class: keepalived
#
# This class manage keepalived server installation and configuration. 
#
class keepalived {

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

	file{"/etc/keepalived/conf.d/real_${name}.conf":
		ensure => present,
		content => template("keepalived/real_server.erb"),
		require => File["/etc/keepalived/conf.d"]
		notify => Exec["reload-keepalived"],
	}
}
