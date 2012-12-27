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

  buildbot::user_homedir { "buildbot":
    group    => "buildbot",
    fullname => "buildbot shared user",
    ingroups => [],
  }
}
