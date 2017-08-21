# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.ssh.insert_key = false
  config.vm.box = "bento/ubuntu-16.04"
  config.vm.provider :virtualbox do |vb|
    vb.memory = 2048
    vb.cpus = 1
    vb.customize [
      "modifyvm", :id,
      "--paravirtprovider", "none"
    ]
  end
end
