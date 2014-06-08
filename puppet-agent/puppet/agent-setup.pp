File {
  owner  => puppet,
  group => puppet,
  mode => 666
}

file { "${settings::localcacert}":
  source => "$ca_pem"
}

file { "${settings::ssldir}/certs/${settings::certname}.pem":
  source => "$cert_pem"
}

file { "${settings::publickeydir}/${settings::certname}.pem":
  source => "$public_pem"
}

file { "${settings::privatekeydir}/${settings::certname}.pem":
  source => "$private_pem",
  mode => 640
}

file { "$info_yaml":
  content => "---\nvardir: ${settings::vardir}\ncertname: ${settings::certname}\n"
}
