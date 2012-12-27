# === Authors
#
# Jason Edgecombe <jason@rampaginggeek.com>
#
# === Copyright
#
# Copyright 2012 Jason Edgecombe, unless otherwise noted.
#
class buildbot::slave {
  include buildbot::base
 
  buildbot::user_homedir { "buildslave":
    group    => "buildslave",
    fullname => "buildbot slave",
    ingroups => [],
  }
}
