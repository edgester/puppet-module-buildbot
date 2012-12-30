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

  $pip_defaults = { 'provider' => 'pip', 'require' => Package['buildbot'] }
  create_resources(package, $buildbot::params::pip_packages,
      $pip_defaults )

  buildbot::user_homedir { "buildbot":
    group    => "buildbot",
    fullname => "buildbot shared user",
    ingroups => [],
  }
}
