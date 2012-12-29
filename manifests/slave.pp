# === Authors
#
# Jason Edgecombe <jason@rampaginggeek.com>
#
# === Copyright
#
# Copyright 2012 Jason Edgecombe, unless otherwise noted.
#
class buildbot::slave( $user="buildslave", $group="buildbot", $project_dir, $master_host_port, $slave_name, $slave_password ) {
  include buildbot::base

  $slave_install_command = "buildslave create-slave $project_dir $master_host_port $slave_name $slave_password"

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
    path    => ['/usr/local/bin','/usr/bin','/bin'],
    creates => "$project_dir/buildbot.tac",
    user    => $user,
    group   => $group,
    require => [ Class['buildbot::install::git'], File[$project_dir] ],
  }
}
