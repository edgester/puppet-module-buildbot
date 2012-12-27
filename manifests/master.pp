# === Authors
#
# Jason Edgecombe <jason@rampaginggeek.com>
#
# === Copyright
#
# Copyright 2012 Jason Edgecombe, unless otherwise noted.
#
class buildbot::master( $user="buildmaster", $group="buildbot", $project_dir ) {
  include buildbot::base

  buildbot::user_homedir { $user:
    group    => $group,
    fullname => "buildbot master",
    ingroups => [],
  }

  file { $project_dir :
    ensure => directory,
    owner  => $user,
    group  => $group,
  }
  
  exec { "buildbot create-master $project_dir":
    path    => ['/usr/bin','/bin'],
    creates => "$project_dir/buildbot.tac",
    user    => $user,
    group   => $group,
    require => [ Class['buildbot::install::git'], File[$project_dir] ],
  }
}
