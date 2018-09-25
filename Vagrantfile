# -*- mode: ruby -*-
# vi: set ft=ruby sts=2 et ai :

ENV["LC_ALL"] = "en_US.UTF-8"

# test IPA migration

Vagrant.configure("2") do |config|
  config.vm.box = "centos/7"

  config.vm.provision "shell", inline: <<-SHELL
    yum install -y ipa-server
  SHELL

  config.vm.provider "virtualbox" do |vb|
    vb.linked_clone = true
  end

  # build head node
  config.vm.define "source" do |source|
    source.vm.network "private_network", ip: "10.11.5.2"
    source.vm.provider "virtualbox" do |vb|
      vb.memory = 512
    end
    source.vm.provision "shell", inline: <<-SHELL
      hostname ipa1.surfeit.io
      ipa-server-install -p ins1106wifi -a ins1106wifi -n ipa.surfeit.io -r SURFEIT.IO --mkhomedir -N -U
    SHELL
  end

  config.vm.define "target" do |target|
    target.vm.network "private_network", ip: "10.11.5.3"
    target.vm.provider "virtualbox" do |vb|
      vb.memory = 512
    end
    target.vm.provision "shell", inline: <<-SHELL
      hostname ipa2.surfeit.io
    SHELL
  end

end
