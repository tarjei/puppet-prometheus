# Class: prometheus::node_exporter
#
# This module manages prometheus node node_exporter
#
# Parameters:
#  
#  [*manage_user*]
#  Whether to create user for prometheus or rely on external code for that
#         
#  [*user*]
#  User running prometheus
#
#  [*manage_group*]
#  Whether to create user for prometheus or rely on external code for that
#
#  [*purge_config_dir*]
#  Purge config files no longer generated by Puppet
#
#  [*group*]  
#  Group under which prometheus is running
#  
#  [*bin_dir*]
#  Directory where binaries are located
#
#  [*arch*]
#  Architecture (amd64 or i386)
#
#  [*version*]
#  Prometheus node node_exporter release
# 
#  [*install_method*]
#  Installation method: url or package (only url is supported currently)
#  
#  [*os*]
#  Operating system (linux is the only one supported)
#
#  [*download_url*]  
#  Complete URL corresponding to the Prometheus node node_exporter release, default to undef
#
#  [*download_url_base*]
#  Base URL for prometheus node node_exporter
#
#  [*download_extension*]
#  Extension of Prometheus node node_exporter binaries archive
#
#  [*package_name*]
#  Prometheus node node_exporter package name - not available yet
#
#  [*package_ensure*] 
#  If package, then use this for package ensure default 'latest'
#
#  [*collectors*]
#  The set of node node_exporter collectors
#
#  [*extra_options*]
#  Extra options added to prometheus startup command
#
#  [*service_enable*]
#  Whether to enable or not prometheus node node_exporter service from puppet (default true)
#
#  [*service_ensure*]
#  State ensured from prometheus node node_exporter service (default 'running')
#
#  [*manage_service*]
#  Should puppet manage the prometheus node node_exporter service? (default true)
#
#  [*restart_on_change*]
#  Should puppet restart prometheus node node_exporter on configuration change? (default true)
#
#  [*init_style*]
#  Service startup scripts style (e.g. rc, upstart or systemd)
#
# Actions:
#
# Requires: see Modulefile
#
# Sample Usage:
#
class prometheus::node_exporter (
  $manage_user          = true,
  $user                 = $::prometheus::params::user,
  $manage_group         = true,
  $purge_config_dir     = true,
  $group                = $::prometheus::params::group,
  $bin_dir              = $::prometheus::params::bin_dir,
  $arch                 = $::prometheus::params::arch,
  $version              = $::prometheus::params::node_exporter_version,
  $install_method       = $::prometheus::params::install_method,
  $os                   = $::prometheus::params::os,
  $download_url         = undef,
  $download_url_base    = $::prometheus::params::node_exporter_download_url_base,
  $download_extension   = $::prometheus::params::node_exporter_download_extension,
  $package_name         = $::prometheus::params::node_exporter_package_name,
  $package_ensure       = $::prometheus::params::node_exporter_package_ensure,
  $collectors           = $::prometheus::params::node_exporter_collectors,
  $extra_options        = undef,
  $config_mode          = $::prometheus::params::config_mode,
  $service_enable       = true,
  $service_ensure       = 'running',
  $manage_service       = true,
  $restart_on_change    = true,
  $init_style           = $::prometheus::params::init_style,
) inherits prometheus::params {
  $real_download_url    = pick($download_url, "${download_url_base}/download/${version}/${package_name}-${version}.${os}-${arch}.${download_extension}")
  validate_bool($purge_config_dir)
  validate_bool($manage_user)
  validate_bool($manage_service)
  validate_bool($restart_on_change)
  validate_array($collectors)
  
  $notify_service = $restart_on_change ? {
    true    => Class['::prometheus::node_exporter::run_service'],
    default => undef,
  }

  anchor {'node_exporter_first': }
  ->
  class { '::prometheus::node_exporter::install': } ->
  class { '::prometheus::node_exporter::config':
    purge  => $purge_config_dir,
    notify => $notify_service,
  } ->
  class { '::prometheus::node_exporter::run_service': } ->
  anchor {'node_exporter_last': }
}
