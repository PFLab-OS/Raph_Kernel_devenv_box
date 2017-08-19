# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.ssh.insert_key = false
  config.vm.box = "ubuntu/xenial64"
  config.vm.provider :virtualbox do |vb|
    vb.memory = 2048
    vb.cpus = 1
  end
end
