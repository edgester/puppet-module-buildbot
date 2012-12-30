# === Authors
#
# Jason Edgecombe <jason@rampaginggeek.com>
#
# === Copyright
#
# Copyright 2012 Jason Edgecombe, unless otherwise noted.
#
define buildbot::slave::instance( $user="buildslave", $group="buildbot",
                       $project_dir, $master_host_port,
                       $slave_name, $slave_password,
                       $info_source='', $info_template='',
                       $admin_contact='Your Name Here <admin@youraddress.invalid>' ) {
  include buildbot::base
  include buildbot::master_slave_barrier

  # configuration
  $config_files          = ["$project_dir/info/admin","$project_dir/info/host"]

  # commands to work with the buildslave
  $slave_install_command = "buildslave create-slave $project_dir $master_host_port $slave_name $slave_password"
  $slave_start_command   = "buildslave start --quiet $project_dir"
  $slave_restart_command = "buildslave restart $project_dir"
  $slave_status_command  = "/bin/kill -0 `/bin/cat $project_dir/twistd.pid`"

  # resource defaults
  File {
    owner => $user,
    group => $group,
    mode  => 0600,
  }

  Exec {
    path  => ['/usr/local/bin','/usr/bin','/bin'],
    cwd   => $project_dir,
    user  => $user,
    group => $group,
  }

  # Fail gracefully if user tries to supply both source and template
  if $info_template and $info_source {
    fail('You cannot supply both template and source to the buildbot::slave class')
  }

  # If nothing is specified, default to our slave info template
  if $info_template == '' and $info_source == '' {
    $slave_info_template = template('buildbot/host.erb')
  } elsif $info_source != '' {
    $slave_info_source = $info_source
  } elsif $info_template != '' {
    $slave_info_template = $info_template
  } 

  buildbot::user_homedir { $user:
    group    => $group,
    fullname => "buildbot slave",
    ingroups => [],
  }

  file { $project_dir :
    ensure => directory,
    mode  => 0700,
  }

  exec { $slave_install_command:
    path    => $path,
    creates => "$project_dir/buildbot.tac",
    require => [ Class['buildbot::install::git'], File[$project_dir] ],
  }

  # put the slave info file into place
  file { "$project_dir/info/host":
    content => $slave_info_template,
    source  => $slave_info_source,
    require => Exec[$slave_install_command],
  }

  # put the slave admin file into place
  file { "$project_dir/info/admin":
    content => $admin_contact,
    require => [ Exec[$slave_install_command],
                 Class['buildbot::master_slave_barrier'] ]
  }

  # start the build slave and restart if it isn't running
  exec { $slave_start_command:
    unless    => $slave_status_command,
    require   => File[$config_files],
  }

  # restart the build slave if files are changed
  exec { $slave_restart_command:
    refreshonly => true,
    require     => File[$config_files],
    subscribe   => File[$config_files],
  }

  # start the buildslave at boot-time via cron
  cron {"buildslave_$project_dir":
    user    => $user,
    command => $slave_start_command,
    special => 'reboot',
  }
}
