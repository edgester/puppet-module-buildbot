# === Authors
#
# Jason Edgecombe <jason@rampaginggeek.com>
#
# === Copyright
#
# Copyright 2012 Jason Edgecombe, unless otherwise noted.
#
class buildbot::params {

  case $::osfamily {
    Debian: {
      $package_deps = [ 'adduser', 'build-essential', 'cvs', 'debhelper',
                        'dpkg', 'git-core', 'python', 'python-central',
                        'python-jinja', 'python-cjson', 'python-anyjson',
                        'python-twisted', 'python-twisted-core',
                        'python-twisted-mail', 'python-twisted-words',
                        'texinfo' ]
      # python-json, python-jinja, git, and cvs are non-core deps
    }
    default: {
      fail("The ${module_name} module is not supported on ${::osfamily} based systems")
    }
  }
}
