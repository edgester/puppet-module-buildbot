# === Authors
#
# Jason Edgecombe <jason@rampaginggeek.com>
#
# === Copyright
#
# Copyright 2012 Jason Edgecombe, unless otherwise noted.
#
define buildbot::master::instance( $user="buildmaster", $group="buildbot",
                                   $config, $project_dir ) {
  include buildbot::base
  include buildbot::master_slave_barrier

  # configuration
  $config_files          = ['master_config']

  # commands to work with the buildbot master
  $master_install_command = "buildbot create-master $project_dir"
  $master_start_command   = "buildbot start --quiet $project_dir"
  $master_restart_command = "buildbot restart --quiet $project_dir"
  $master_status_command  = "/bin/kill -0 `/bin/cat $project_dir/twistd.pid`"

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
                                  
  buildbot::user_homedir { $user:
    group    => $group,
    fullname => "buildbot master",
    ingroups => [],
  }

  file { $project_dir :
    ensure => directory,
    mode   => 0700,
  }
  
  exec { $master_install_command :
    creates => "$project_dir/buildbot.tac",
    require => [ Class['buildbot::install::git'], File[$project_dir] ],
  }

  file { 'master_config':
    path    => "$project_dir/master.cfg",
    source  => $config,
    require => File[$project_dir],
  }

  # start the build master and restart if it isn't running
  exec { $master_start_command:
    unless    => $master_status_command,
    require   => [ File[$config_files],
                   Exec[$master_install_command] ],
  }

  # restart the build master if files are changed
  exec { $master_restart_command:
    refreshonly => true,
    require     => [ File[$config_files], Exec[$master_install_command]],
    subscribe   => File[$config_files],
  }

  # start the buildmaster at boot-time via cron
  cron {"buildmaster_$project_dir":
    user    => $user,
    command => $master_start_command,
    special => 'reboot',
  }
}
