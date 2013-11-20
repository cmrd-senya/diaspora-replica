class diaspora (
  $hostname,
  $app_directory = '/home/diaspora',
  $user          = 'diaspora',
  $group         = 'diaspora',
  $db_provider   = 'mysql',
  $db_host       = 'localhost',
  $db_port       = '3306',
  $db_name       = 'diaspora_development',
  $db_username   = 'diaspora',
  $db_password   = 'diaspora',
) {

  class { 'diaspora::dependencies': }
  class { 'diaspora::ruby': }
  class { 'diaspora::user':
    home  => $app_directory,
    user  => $user,
    group => $group
  }

  class { 'diaspora::database':
    db_provider => $db_provider,
    db_host     => $db_host,
    db_port     => $db_port,
    db_name     => $db_name,
    db_username => $db_username,
    db_password => $db_password
  }

  file {
    "$app_directory/shared/config/database.yml":
      content => template('diaspora/database.yml.erb'),
      owner   => $user,
      group   => $group,
      require => Class['diaspora::user'];

    "$app_directory/shared/config/diaspora.yml": # TODO prepare a first configuration
      content => template('diaspora/diaspora.yml.erb'),
      owner   => $user,
      group   => $group,
      require => Class['diaspora::user'];
  }

  class { 'nginx': }

  nginx::resource::upstream { 'diaspora_app':
    ensure  => present,
    members => ['localhost:3000']
  }

  nginx::resource::vhost { $hostname:
    ensure   => present,
    proxy    => 'http://diaspora_app'
  }
}