# Class: keepalived
#
# This class manage keepalived server installation and configuration.
#
class keepalived (
    $email_notifications = 'root@localhost',
    $smtp_server = '127.0.0.1',
    ) {

    file { "/etc/sysctl.d/60-arp_dsr.conf":
                owner   => root,
                group   => root,
                mode    => 644,
        source => "puppet:///modules/keepalived/arp_dsr.conf",
    }

    file { "/etc/sysctl.d/60-ip_forward.conf":
                owner   => root,
                group   => root,
                mode    => 644,
        source => "puppet:///modules/keepalived/ip_forward.conf",
    }

    package { ['keepalived', 'ipvsadm']:
        ensure => installed
    }

    service { keepalived:
        ensure => running,
        enable => true,
        require => Package["keepalived"],
    }

    exec{"reload-keepalived":
        command => "/etc/init.d/keepalived reload",
        refreshonly => true,
        require => Package["keepalived"],
    }

    file{"/etc/keepalived/keepalived.conf":
        ensure => present,
        content => template("keepalived/etc/keepalived/keepalived.conf.erb"),
        notify => Service["keepalived"],
    }

    file{"/etc/keepalived/conf.d": ensure => directory}

    file {"/etc/keepalived/vrrp_state.sh":
        mode => 0755,
        owner => root,
        group => 0,
        source => "puppet:///modules/keepalived/etc/keepalived/vrrp_state.sh",
        require => Package["keepalived"],
        notify => Exec["reload-keepalived"],
    }

    file {"/etc/keepalived/ha_script.sh":
        mode => 0755,
        owner => root,
        group => 0,
        source => "puppet:///modules/keepalived/etc/keepalived/ha_script.sh",
        require => Package["keepalived"],
        notify => Exec["reload-keepalived"],
    }

    file {"/etc/keepalived/bypass_ipvs.sh":
        mode => 0755,
        owner => root,
        group => 0,
        source => "puppet:///modules/keepalived/etc/keepalived/bypass_ipvs.sh",
        require => Package["keepalived"],
        notify => Exec["reload-keepalived"],
    }
}
