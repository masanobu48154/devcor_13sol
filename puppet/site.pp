$if_name = "ipip1"
$server01_ip_address = "192.168.1.1/24"
$server01_global_ip = "172.20.0.21"
$server01_subnet = "192.168.1.0/24"
$server02_ip_address = "192.168.2.1/24"
$server02_global_ip = "172.20.0.22"
$server02_subnet = "192.168.2.0/24"
$ntp_servers = [
  "0.north-america.pool.ntp.org",
  "1.north-america.pool.ntp.org",
  "2.north-america.pool.ntp.org",
  "3.north-america.pool.ntp.org",
]

class configure_interface (String $if_name, String $ip_address, String $local_ip, String $remote_ip) {

  file { 'interface_config_file':
    path => "/root/network-script.sh",
    content => template("$settings::manifest/network-interface.tmpl"),
    ensure => present,
    mode => "744",
  }

  exec { 'execute_script':
    command => '/root/network-script.sh >> /root/network-script.log',
    require => File['interface_config_file'],
  }

}

class configure_route (String $route, String $if_name) {

  exec { 'add_route':
    command => "/sbin/ip route replace $route dev $if_name"
  }

}


node 'server01' {

  class { 'configure_interface':
    if_name => "$if_name",
    ip_address => "$server01_ip_address",
    local_ip => "$server01_global_ip",
    remote_ip => "$server02_global_ip",
  }

  class { 'configure_route':
    route => "$server02_subnet",
    if_name => "$if_name",
  }

  class { 'ntp':
    servers => $ntp_servers,
  }

}

node 'server02' {

  class { 'configure_interface':
    if_name => "$if_name",
    ip_address => "$server02_ip_address",
    local_ip => "$server02_global_ip",
    remote_ip => "$server01_global_ip",
  }

  class { 'configure_route':
    route => "$server01_subnet",
    if_name => "$if_name",
  }

  class { 'ntp':
    servers => $ntp_servers,
  }

}
