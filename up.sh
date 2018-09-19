#!/bin/bash

# TODO pull names from Vagrantfile?

for name in head node-{1..4}
do
  vagrant up $name &
done
wait

vagrant ssh-config > .ssh-config
