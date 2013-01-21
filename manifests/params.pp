# === Authors
#
# Jason Edgecombe <jason@rampaginggeek.com>
#
# === Copyright
#
# Copyright 2012 Jason Edgecombe, unless otherwise noted.
#
class buildbot::params {

  case $::operatingsystem {
    Debian: {
      $package_deps = [ 'adduser', 'build-essential', 'cvs', 'debhelper',
                        'dpkg', 'git-core', 'python', 'python-central',
                        'python-dateutil', 'python-jinja2',
                        'python-simplejson', 'python-pip',
                        'python-pysqlite2', 'python-twisted',
                        'python-twisted-core', 'python-twisted-mail',
                        'python-twisted-web', 'python-twisted-words',
                        'sqlite3', 'texinfo' ]

      # list of packages to be installed via pip
      # ensure may be 'installed', 'latest', or a specific version
      $pip_packages = {
        'sqlalchemy-migrate' => { 'ensure' => '0.7.1' },
        'SQLAlchemy' => { 'ensure' => '0.7.9' },
      }
    }
    Ubuntu: {
      $package_deps = [ 'adduser', 'build-essential', 'cvs', 'debhelper',
                        'dpkg', 'git-core', 'python', 'python-central',
                        'python-dateutil', 'python-jinja2',
                        'python-simplejson', 'python-pip',
                        'python-pysqlite2', 'python-twisted',
                        'python-twisted-core', 'python-twisted-mail',
                        'python-twisted-web', 'python-twisted-words',
                        'sqlite3', 'texinfo' ]

      # list of packages to be installed via pip
      # ensure may be 'installed', 'latest', or a specific version

      $pip_packages = {
        'decorator'          => { 'ensure' => 'installed' },
        'SQLAlchemy'         => { 'ensure' => '0.7.9' },
        'sqlalchemy-migrate' => { 'ensure' => 'latest' },
      }
    }
    default: {
      fail("The ${module_name} module is not supported on ${::osfamily} based systems")
    }
  }
}
