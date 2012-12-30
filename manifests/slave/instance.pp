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

  $path                  = ['/usr/local/bin','/usr/bin','/bin']
  $config_files          = ["$project_dir/info/admin","$project_dir/info/host"]

  # commands to work with the buildslave
  $slave_install_command = "buildslave create-slave $project_dir $master_host_port $slave_name $slave_password"
  $slave_start_command   = "buildslave start $project_dir"
  $slave_restart_command = "buildslave restart $project_dir"
  $slave_status_command  = "/bin/kill -0 `/bin/cat $project_dir/twistd.pid`"

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
    owner  => $user,
    group  => $group,
  }

  exec { $slave_install_command:
    path    => $path,
    creates => "$project_dir/buildbot.tac",
    user    => $user,
    group   => $group,
    require => [ Class['buildbot::install::git'], File[$project_dir] ],
  }

  # put the slave info file into place
  file { "$project_dir/info/host":
    owner   => $user,
    group   => $group,
    mode    => 0644,
    content => $slave_info_template,
    source  => $slave_info_source,
    require => Exec[$slave_install_command],
  }

  # put the slave admin file into place
  file { "$project_dir/info/admin":
    owner   => $user,
    group   => $group,
    mode    => 0644,
    content => $admin_contact,
    require => Exec[$slave_install_command],
  }

  # start the build slave and restart if it isn't running
  exec { $slave_start_command:
    cwd       => $project_dir,
    path      => $path,
    user      => $user,
    group     => $group,
    unless    => $slave_status_command,
    refresh   => $slave_restart_command,
    require   => File[$config_files],
    subscribe => File[$config_files],
  }

  # start the buildslave at boot-time via cron
  cron {"buildslave_$project_dir":
    user    => $user,
    command => $slave_start_command,
    special => 'reboot',
  }
}
