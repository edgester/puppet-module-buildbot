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
                        'python-dateutil', 'python-jinja2', 'python-simplejson',
                        'python-migrate', 'python-pip', 'python-sqlalchemy',
                        'python-pysqlite2', 'python-twisted',
                        'python-twisted-core', 'python-twisted-mail',
                        'python-twisted-web', 'python-twisted-words',
                        'sqlite3', 'texinfo' ]
    }
    default: {
      fail("The ${module_name} module is not supported on ${::osfamily} based systems")
    }
  }
}
