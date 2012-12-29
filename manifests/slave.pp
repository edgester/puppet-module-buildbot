# === Authors
#
# Jason Edgecombe <jason@rampaginggeek.com>
#
# === Copyright
#
# Copyright 2012 Jason Edgecombe, unless otherwise noted.
#
class buildbot::slave( $user="buildslave", $group="buildbot", $project_dir,
                       $master_host_port, $slave_name, $slave_password,
                       $info_source='', $info_template='' ) {
  include buildbot::base

  $slave_install_command = "buildslave create-slave $project_dir $master_host_port $slave_name $slave_password"

  # Fail gracefully if user tries to supply both source and template
  if $info_template and $info_source {
    fail('You cannot supply both template and source to the buildbot::slave class')
  }

  # If nothing is specified, default to our slave info template
  if $info_template == '' and $info_source == '' {
    $slave_info_template = template('buildbot/host.erb')
  } elsif $info_source != '' {
    $slave_info_source = $info_source
  } elsif $info_template != '' {
    $slave_info_template = $info_template
  } 

  buildbot::user_homedir { $user:
    group    => $group,
    fullname => "buildbot slave",
    ingroups => [],
  }

  file { $project_dir :
    ensure => directory,
    owner  => $user,
    group  => $group,
  }

  exec { $slave_install_command:
    path    => ['/usr/local/bin','/usr/bin','/bin'],
    creates => "$project_dir/buildbot.tac",
    user    => $user,
    group   => $group,
    require => [ Class['buildbot::install::git'], File[$project_dir] ],
  }

  # put the slave info file into place
  file { "$project_dir/info/host":
    owner   => $user,
    group   => $group,
    mode    => 0644,
    content => $slave_info_template,
    source  => $slave_info_source,
    require => Exec[$slave_install_command],
  }
}
