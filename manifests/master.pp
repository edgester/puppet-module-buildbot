# === Authors
#
# Jason Edgecombe <jason@rampaginggeek.com>
#
# === Copyright
#
# Copyright 2012 Jason Edgecombe, unless otherwise noted.
#
class buildbot::master {
  include buildbot::base

  buildbot::user_homedir { "buildmaster":
    group    => "buildmaster",
    fullname => "buildbot master",
    ingroups => [],
  }
}
