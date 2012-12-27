# === Authors
#
# Jason Edgecombe <jason@rampaginggeek.com>
#
# === Copyright
#
# Copyright 2012 Jason Edgecombe, unless otherwise noted.
#
#
class buildbot::install::git( $directory='/usr/local/buildbot-src',
      $owner='buildbot',
      $group='buildbot',
      $source='git://github.com/buildbot/buildbot.git',
      $revision='master' ) {
  include buildbot::base

  $install_command="python setup.py build ; python setup.py install"
        
  vcsrepo { $directory:
    ensure   => present,
    provider => git,
    source   => $source,
    revision => $revision,
    owner    => $owner,
    group    => $group,
    require  => Class['buildbot::base']
  }

  exec { $install_command: 
    cwd     => $directory,
    path    => ["/usr/bin", "/usr/sbin"],
    creates => '/usr/bin/buildbot',
    require => Vcsrepo[$directory],
  }
}
