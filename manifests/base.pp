# === Authors
#
# Jason Edgecombe <jason@rampaginggeek.com>
#
# === Copyright
#
# Copyright 2012 Jason Edgecombe, unless otherwise noted.
#
class buildbot::base {
  include apt
  include buildbot::params
  
  package { 'buildbot' :
    ensure => present,
    name   => $buildbot::params::package_deps,
  }

  package { 'python_sqlalchemy_migrate' :
    name     => 'sqlalchemy-migrate==0.7.1',
    ensure   => present,
    provider => pip,
    require  => Package['buildbot'],
  }

  buildbot::user_homedir { "buildbot":
    group    => "buildbot",
    fullname => "buildbot shared user",
    ingroups => [],
  }
}
