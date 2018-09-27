# -*- mode: ruby -*-
# vi: set ft=ruby sts=2 et ai :

Vagrant.configure("2") do |config|
  config.vm.box = "centos/7"
  config.vm.provider "virtualbox" do |vb|
    vb.linked_clone = true
  end

  config.vm.define "node" do |node|
    node.vm.hostname = "node"
    node.vm.network "private_network", ip: "10.11.5.10"
    node.vm.provider "virtualbox" do |vb|
      vb.memory = 512
    end
    node.vm.provision "shell", path: "slurm.sh"
  end
end
