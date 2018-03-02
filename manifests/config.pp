class lldpd::config {

  $addresses   = $::lldpd::addresses
  $chassis_id  = $::lldpd::chassis_id
  $class       = $::lldpd::class
  $interfaces  = $::lldpd::interfaces
  $snmp_socket = $::lldpd::snmp_socket

  file { '/etc/lldpd.d':
    ensure  => directory,
    owner   => 0,
    group   => 0,
    mode    => '0644',
    purge   => true,
    recurse => true,
  }

  if $addresses {
    $_addresses = join($addresses, ',')
  }

  if $chassis_id {
    $_chassis_id = join($chassis_id, ',')
  }

  if $interfaces {
    $_interfaces = join($interfaces, ',')
  }

  $_enable_cdpv = [ $::lldpd::enable_cdpv1, $::lldpd::enable_cdpv2 ]
  $_false_false = [false, false]
  $_true_true   = [true, true]
  $_force_true  = ['force', true]
  $_true_force  = [true, 'force']
  $_false_true  = [false, true]
  $_false_force = [false, 'force']

  $flags = join(delete_undef_values([
    $addresses ? {
      undef   => undef,
      default => "-m ${_addresses}",
    },
    $chassis_id ? {
      undef   => undef,
      default => "-C ${_chassis_id}",
    },
    $class ? {
      undef   => undef,
      default => "-M ${class}",
    },
    $_enable_cdpv ? {
      $_false_false => undef,
      $_true_true   => '-c',
      $_force_true  => '-cc',
      $_true_force  => '-ccc',
      $_false_true  => '-cccc',
      $_false_force => '-ccccc',
      default       => fail('Invalid combination of CDP parameters'),
    },
    $::lldpd::enable_edp ? {
      true    => '-e',
      'force' => '-ee',
      default => undef,
    },
    $::lldpd::enable_fdp ? {
      true    => '-f',
      'force' => '-ff',
      default => undef,
    },
    $::lldpd::enable_lldp ? {
      'force' => '-l',
      false   => '-ll',
      default => undef,
    },
    $::lldpd::enable_sonmp ? {
      true    => '-s',
      'force' => '-ss',
      default => undef,
    },
    $::lldpd::enable_snmp ? {
      true    => '-x',
      default => undef,
    },
    $interfaces ? {
      undef   => undef,
      default => "-I ${_interfaces}",
    },
    $snmp_socket ? {
      undef   => undef,
      default => "-X ${snmp_socket}",
    },
  ]), ' ')

  case $::osfamily {
    'RedHat': {
      file { '/etc/sysconfig/lldpd':
        ensure  => file,
        owner   => 0,
        group   => 0,
        mode    => '0644',
        content => template("${module_name}/sysconfig.erb"),
      }
    }
    'Debian': {
      file { '/etc/default/lldpd':
        ensure  => file,
        owner   => 0,
        group   => 0,
        mode    => '0644',
        content => template("${module_name}/default.erb"),
      }
    }
    default: {
      # noop
    }
  }
}
