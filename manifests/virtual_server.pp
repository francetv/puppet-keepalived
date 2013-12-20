define keepalived::virtual_server ( 
	$virtual_ipaddress,
	$virtual_server_port,
	$servers = [],
	$virtual_service = '',
	$lb_kind = 'DR',
	$lb_algo = 'wlc') {


	#Construct /etc/keepalived/keepalived.conf
    file {"/etc/keepalived/conf.d/lb_${name}.conf":
        content => template("keepalived/virtual_server.erb"),
        mode => 0644,
        owner => root,
        group => 0,
		notify => Exec["reload-keepalived"],
    } 
}
