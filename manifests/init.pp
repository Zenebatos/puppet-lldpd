# Installs and manages the LLDP agent.
#
# @example Declaring the class
#   include ::lldpd
#
# @example Enabling CDPv1 and CDPv2
#   class { '::lldpd':
#     enable_cdpv1 => true,
#     enable_cdpv2 => true,
#   }
#
# @example Enable SNMP support
#   class { '::lldpd':
#     enable_snmp => true,
#     snmp_socket => ['127.0.0.1', 705],
#   }
#
# @param addresses List of IP addresses to advertise as the management addresses.
# @param chassis_id List of interfaces to use for choosing the MAC address used as the chassis ID.
# @param class Set the LLDP-MED class.
# @param enable_cdpv1 Disable, enable, or force Cisco Discovery Protocol version 1. Both this and the below parameter are combined to form an overall CDP setting, not all combinations are supported by `lldpd`.
# @param enable_cdpv2 Disable, enable, or force Cisco Discovery Protocol version 2. Both this and the above parameter are combined to form an overall CDP setting, not all combinations are supported by `lldpd`.
# @param enable_edp Disable, enable, or force the Extreme Discovery Protocol.
# @param enable_fdp Disable, enable, or force the Foundry Discovery Protocol.
# @param enable_lldp Disable, enable, or force the Link Layer Discovery Protocol.
# @param enable_sonmp Disable, enable, or force the Nortel Discovery Protocol.
# @param enable_snmp Enable or disable the SNMP AgentX sub-agent support.
# @param interfaces List of interfaces to advertise on.
# @param package_name The name of the package.
# @param service_name Name of the service.
# @param snmp_socket Absolute path to an on-disk snmp socket OR an IP & port pair prefixed with 'tcp:'. Ex: 'tcp:127.0.0.0.1:9001'. Used to establish an SNMP AgentX connection.
class lldpd (
  $addresses    = undef,
  $chassis_id   = undef,
  $class        = undef,
  $enable_cdpv1 = false,
  $enable_cdpv2 = false,
  $enable_edp   = false,
  $enable_fdp   = false,
  $enable_lldp  = true,
  $enable_sonmp = false,
  $enable_snmp  = false,
  $interfaces   = undef,
  $package_name = $::lldpd::params::package_name,
  $service_name = $::lldpd::params::service_name,
  $snmp_socket  = undef,
) inherits ::lldpd::params {

  if $addresses {
    validate_array($addresses)
    validate_ip_address($addresses)
  }

  if $chassis_id {
    validate_array($chassis_id)
    validate_string($chassis_id)
  }

  if $class {
    validate_integer($class, 4, 1)
  }

  if $enable_cdpv1 != "force" {
    validate_bool($enable_cdpv1)
  }

  if $enable_cdpv2 != "force" {
    validate_bool($enable_cdpv2)
  }

  if $enable_edp != "force" {
    validate_bool($enable_edp)
  }

  if $enable_fdp != "force" {
    validate_bool($enable_fdp)
  }

  if $enable_lldp != "force" {
    validate_bool($enable_lldp)
  }

  if $enable_sonmp != "force" {
    validate_bool($enable_sonmp)
  }

  validate_bool($enable_snmp)

  if $interfaces {
    validate_array($interfaces)
    validate_string($interfaces)
  }

  validate_string($package_name)

  validate_string($service_name)

  if $snmp_socket {
    validate_string($snmp_socket)
  }

  class { '::lldpd::install': }
  class { '::lldpd::config':  }
  class { '::lldpd::service': }

  Class['::lldpd::install'] -> Class['::lldpd::config']
    ~> Class['::lldpd::service']
}
