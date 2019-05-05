# -*- mode: ruby -*-
# # vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.ssh.insert_key = false
  config.ssh.username = "core"
  config.vm.synced_folder ".", "/vagrant", disabled: true

  config.vm.provider :libvirt do |libvirt|
    libvirt.driver = "kvm"
  end
end
