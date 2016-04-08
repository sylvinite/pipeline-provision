# Playbooks and scripts for deploying NGI pipeline and Piper. 

Ansible playbooks for production usage on Irma to be run on irma3. 

## Usage 

Run `source /lupus/ngi/irma3/.bashrc` to setup environment variables for the virtual Ansible environment. This will force a suitable umask and set your GID to ngi-sw, as all files installed need to be setup so that they are group readable/writeable, and readable for world. 

When the environment variables have been loaded you should be able to issue the command `source /lupus/ngi/irma3/ansible-env/bin/activate` to load the Python environment for Ansible and `sync.py`. Now you should be able to navigate to `/lupus/ngi/irma3/deploy` and install (i.e. download, setup/compile, and provision configs) required software under the `/lupus/ngi/` directory tree. 

In the simplest case this is done with the command `ansible-playbook install.yml`. 

Important configuration values are at the moment set in the file `host_vars/127.0.0.1` (global values), and respective role's `defaults/main.yml` file. 

When the software has been setup locally under `/lupus/ngi/` on irma3 we can sync it over to the irma cluster by having the ansible-env loaded and then running `python sync.py <remote dest>` (if no `remote dest` is supplied it is assumed to go under `/lupus/ngi`). The script will prompt you for your UPPMAX password and then your SNIC-SENSE factor, and then initiate the rsync of all files residing under `/lupus/ngi` on irma3 (except the `irma3` subdirectory). 

Log files of software installed by Ansible ends up under `/lupus/ngi/irma3/log/ansible.log`, and for the sync under `/lupus/ngi/irma3/log/rsync.log`. 

A manual step is required for generating the GATK indices. After everything has been deployed on the cluster the script `/lupus/ngi/sw/piper/gen_GATK_ref.sh` has to be run. 

## Bootstrapping the playbook environment 

This repo should be checked out to e.g. `/lupus/ngi/irma3/deploy`. Then the file `bootstrap/bashrc` should be copied to `/lupus/ngi/irma3/bashrc` and sourced every time a user wants to work. 

The latest version of virtualenv was downloaded and then locally run to setup a virtual Python environment: `/lupus/ngi/irma3/virtualenv-15.0.0/virtualenv.py -p /usr/bin/python2.7 /lupus/ngi/irma3/ansible-env`. 

After activating the environment with `source /lupus/ngi/irma3/ansible-env/bin/activate` Ansible was installed with `pip install ansible`.
 
Then anaconda was downloaded manually (**TODO: do this in the playbook instead?**) and installed via the interactive guide under `/lupus/ngi/sw/anaconda` (some Ansible roles later uses anaconda to setup the NGI virtual environment.)

To sync over data to the cluster we need the pexpect Python module. Load the ansible-env Python environment and then do a `pip install pexpect`. 

## Some operational dependencies

- When developing roles make sure that directories are created with the setgid flag `mode=g+s`, as that will act as an extra insurance that the correct group owner gets set on new files created in the dirs (`ngi-sw` or `ngi`). This is needed as we can't have a setgid on the root folder `/lupus/ngi` (as that one is owned by `ngi-sw` and we need subdirs owned by `ngi`). 
- Requires a working connection to `charon` or `charon-dev` with suitable API token. 
- Requires a valid GATK key placed under `playbooks/files`, and that the filename is specified in the `gatk_key` variable in `host_vars/127.0.0.1/main.yml`. 
- Requires a `charon_credentials.yml` to be placed under `host_vars/127.0.0.1/` with appropriate values set for the variables `charon_base_url`, `charon_api_token_upps` and `charon_api_token_sthlm`. (TODO: Contemplate whether this should be structured otherwise) 
- For deploying sw the user needs to be in both the `ngi-sw` and the `ngi` groups. Everything under `/lupus/ngi` will be owned by `ngi-sw`, except the `db` and `log` dirs that will be owned by `ngi`. That way a select few people can write new programs and configs, but all NGI functional accounts (`funk_004`, `funk_006` etc) can write log files, to the SQL database, etc. 

Two manual steps are also needed for each func account. In respective `~/.bashrc` the following snippet needs to be added: 

	# Enter the ngi_pipeline working environment
	source /lupus/ngi/conf/sourceme_<site>.sh
	source activate NGI

where `<site>` should be `upps` for `funk_004', and `sthlm` for `funk_006`. 

Then to get the crontab for each func account loaded a manual `crontab /lupus/ngi/conf/crontab_<site>` needs to be run. The crontab files includes an autoreload, so next time a new versoin of the crontab is deployed the crontab for the func account should after a while be appropriately reloaded. 

## Note on re-compiling software

FIXME: Need to remove the file that is specified in the task's `creates=` field. Otherwise the compile step will be ignored.  
