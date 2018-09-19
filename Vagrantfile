# -*- mode: ruby -*-
# vi: set ft=ruby sts=2 et ai :

ENV["LC_ALL"] = "en_US.UTF-8"

# TODO
# - private network, access only through head
# - NFS /home
# - munge/slurm
# - openmpi
# - freeipa
# - jupyterhub

n_node = 4

Vagrant.configure("2") do |config|
  config.vm.box = "centos/7"
  # config.vm.box_check_update = false
  # config.vm.network "forwarded_port", guest: 80, host: 8080
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"
  # config.vm.network "private_network", ip: "192.168.33.10"
  # config.vm.network "public_network"
  # config.vm.synced_folder "../data", "/vagrant_data"
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL

  config.vm.provision "shell", inline: <<-SHELL
  yum install -y nfs-utils
  echo "10.11.5.1 head" >> /etc/hosts
  for i in {1..#{n_node}}; do
    echo "10.11.5.1$i node-$i" >> /etc/hosts
  done
  SHELL
  config.vm.provider "virtualbox" do |vb|
    vb.linked_clone = true
  end

  # build head node
  config.vm.define "head" do |head|
    head.vm.hostname = "head"
    head.vm.network "private_network", ip: "10.11.5.1"
    head.vm.provider "virtualbox" do |vb|
      vb.memory = 512
    end
    head.vm.provision "shell", inline: <<-SHELL
      hostname
      systemctl enable --now nfs
      mkdir -p /opt
      echo "/opt 10.11.5.0/24(rw)" >> /etc/exports
      exportfs -a
      systemctl restart nfs
    SHELL
  end

  (1..n_node).each do |i|
    config.vm.define "node-#{i}" do |node|
      node.vm.hostname = "head-#{i}"
      node.vm.network "private_network", ip: "10.11.5.1#{i}"
      node.vm.provider "virtualbox" do |vb|
        vb.memory = 256
      end
      node.vm.provision "shell", inline: <<-SHELL
	hostname
        mkdir -p /opt
	mount.nfs head:/opt /opt
      SHELL
    end
  end
end
