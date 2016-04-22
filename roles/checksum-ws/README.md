Quick-start
-----------

Get going with developing the role by using the supplied Vagrant box.

```
# Do the vagrant dance
vagrant up
vagrant ssh
cd /vagrant
./roles/checksum-ws/bootstrap_vagrant_box.sh

# Run the playbook
ansible-playbook install_checksum.yml 

# Et voila
source ~/checksum_venv/bin/activate
checksum-ws --config ~/checksum_conf/ --port 8080
```

