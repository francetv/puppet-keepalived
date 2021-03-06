# Define : keepalived::real_server
#
# Define a real server.
#
# Parameters :
#        ip
#        port
#        virtual_server_name : name of the related keepalived::virtual_server
#        weight = '100',
#        check_type : MISC_CHECK , TCP_CHECK or HTTP_GET - if not set, the check is a TCP_CHECK on the port
#                check_connect_timeout = '2',
#                check_nb_get_retry = '2',
#                check_delay_before_retry = '2',
#                check_misc_path = '', #for MISC_CHECK
#                check_connect_port = '', #for TCP_CHECK and HTTP_GET
#                check_url_path = '', #for HTTP_GET
#                check_url_digest = '' #for HTTP_GET
define keepalived::real_server (
	$ip,
	$port,
	$weight = '100',
	$inhibit = false,
	$check_type = 'TCP_CHECK',
		$check_connect_timeout = '2',
		$check_nb_get_retry = '2',
		$check_delay_before_retry = '2',
		$check_misc_path = '/etc/keepalived/ha_script.sh',
		$check_misc_options = '',
		$check_connect_port = '',
		$check_url_path = '',
		$check_url_digest = ''
	) {

	if $check_type == 'TCP_CHECK' {
		$real_check_connect_port = $check_connect_port ? {
			'' => $port,
			default => $check_connect_port,
		}
	}

	file{"/etc/keepalived/conf.d/rs_${ip}_${port}.conf":
		ensure => present,
		content => template("keepalived/real_server.erb"),
		notify => Exec["reload-keepalived"],
	}
}
