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
    path    => ['/usr/local/bin','/usr/bin','/bin'],
    creates => "$project_dir/buildbot.tac",
    user    => $user,
    group   => $group,
    require => [ Class['buildbot::install::git'], File[$project_dir] ],
  }

  file { 'master_config':
    path    => "$project_dir/master.cfg",
    source  => $config,
    owner   => $user,
    group   => $group,
    mode    => 0600,
    require => File[$project_dir],
  }
}
