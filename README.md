Fedora CoreOS Vagrant Box Builder
=================================

Tiny project to convert Fedora CoreOS Preview qcow2 images into libvirt (qemu/kvm) compatible Vagrant boxes.

Building a box
--------------

### Build and run as a container

```sh
podman build -t localhost/box-builder:latest .
mkdir output
podman run --rm -v "$(pwd)/output:/output:Z" localhost/box-builder:latest
```

Importing the box
-----------------

```sh
vagrant box add "$(pwd)/output/fedora-coreos.json"
```

Sample Vagrant project
----------------------

```ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'json'

ignition_file = File.join(File.dirname(__FILE__), 'config.ign')

config = {
  :ignition => {
    :version => "3.0.0",
  },
  :passwd => {
    :users => [{
      :name => 'core',
      :sshAuthorizedKeys => ['ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key'],
    }],
  },
}

File.open(ignition_file, "w") { |file| file.puts JSON.generate(config)}
# Systems with SELinux will need to relabel the file.
system("chcon system_u:object_r:virt_content_t:s0 #{ignition_file}")

Vagrant.configure("2") do |config|
  config.vm.box = 'fedora-coreos-preview'
  config.vm.provider :libvirt do |lv|
    lv.memory = 1024
    lv.cpus = 1
    lv.qemuargs :value => '-fw_cfg'
    lv.qemuargs :value => "name=opt/com.coreos/config,file=#{ignition_file}"
  end
end
```
