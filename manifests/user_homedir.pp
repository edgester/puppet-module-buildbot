define buildbot::user_homedir ($group, $fullname, $ingroups) {
  user { "$name":
    ensure => present,
    comment => "$fullname",
    gid => "$group",
    groups => $ingroups,
    membership => minimum,
    shell => "/bin/bash",
    home => "/home/$name",
    require => Group[$group],
  }

  group { "$name":
    ensure => 'present',
  }
  
  exec { "$name homedir":
    command => "/bin/cp -R /etc/skel/ /home/$name/; /bin/chown -R $name:$group /home/$name",
    creates => "/home/$name",
    require => User[$name],
  }
  
  file { "/home/$name":
    ensure => 'directory',
    owner  => $name,
    group  => $group,
    mode   => 0700,
  }
}
