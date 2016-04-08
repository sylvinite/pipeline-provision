# Playbooks and scripts for deploying NGI pipeline and Piper. 

Ansible playbooks to deploy production instances on Irma from irma3. 

## Usage 

Run `source /lupus/ngi/irma3/bashrc` to setup environment variables for the virtual Ansible environment.
This will force a suitable umask and set your GID to ngi-sw, which makes sure all files installed are setup so that they are properly group readable/writeable, and readable for world. 

Issue the command `source /lupus/ngi/irma3/ansible-env/bin/activate` to load the Python environment for Ansible and `sync.py`.
Navigate to `/lupus/ngi/irma3/deploy` and install (i.e. download, setup/compile and provision set configs) for required the software under `/lupus/ngi/`. 

The simplest example of this is the command `ansible-playbook install.yml`. 

Universal configuration values set in `host_vars/127.0.0.1/main.yml` (global values), and each respective role's in `<role>/defaults/main.yml` file. 

When the software has been setup locally under `/lupus/ngi/` on irma3, sync it over to the irma cluster by having the ansible-env loaded and then run `python sync.py <remote dest>` (if no `remote dest` is supplied it will go under `/lupus/ngi`). The script will prompt you for your UPPMAX password and then your SNIC-SENSE factor, and then initiate the rsync of all files residing under `/lupus/ngi` on irma3 (except the `irma3` subdirectory). 

Log files of software installed by Ansible ends up under `/lupus/ngi/irma3/log/ansible.log`, and for the sync under `/lupus/ngi/irma3/log/rsync.log`. 

A manual step is required for generating the GATK indices. After everything has been deployed on the cluster run the script `/lupus/ngi/sw/piper/gen_GATK_ref.sh`. 

## Bootstrapping the playbook environment 

Check out this repo to e.g. `/lupus/ngi/irma3/deploy`. Then copy the file `bootstrap/bashrc` to `/lupus/ngi/irma3/bashrc`. This file has to be sourced every time a user wants to work. 

The latest version of virtualenv was downloaded and then locally run to setup the virtual Python environment. The command used was: `/lupus/ngi/irma3/virtualenv-15.0.0/virtualenv.py -p /usr/bin/python2.7 /lupus/ngi/irma3/ansible-env`. 

After activating the environment with `source /lupus/ngi/irma3/ansible-env/bin/activate` Ansible was installed with `pip install ansible`.
 
Anaconda was downloaded manually (**TODO: do this in the playbook instead?**) and installed via the interactive guide under `/lupus/ngi/sw/anaconda` (some Ansible roles later uses anaconda to setup the NGI virtual environment.)

To sync over data to the cluster the pexpect Python module is required. Load the ansible-env Python environment and then run `pip install pexpect`. 

Finnally the setgid flag was set by running `chmod -R g+s /lupus/ngi/sw/ /lupus/ngi/irma3/`.

## Operational dependencies
- When developing roles make sure that directories are created with the setgid flag `mode=g+s`, as it will act as an extra insurance that the new files created in the dirs (`ngi-sw` or `ngi`) recieve the correct owner. This extra step is necessary as setgid can't be set for the root folder `/lupus/ngi` (as it is owned by `ngi-sw` and the deployment require subdirs owned by `ngi`). 
- A working connection to `charon` or `charon-dev` as well as a suitable API token. 
- A valid GATK key placed under `deploy/files`. The filename must be specified in the `gatk_key` variable in `host_vars/127.0.0.1/main.yml`. 
- A `charon_credentials.yml` file under `host_vars/127.0.0.1/` with appropriate values set for the variables `charon_base_url`, `charon_api_token_upps` and `charon_api_token_sthlm`. (TODO: Contemplate whether this should be structured otherwise) 
- If the deployer needs to deploy to sw the deployer needs to be in both the `ngi-sw` and the `ngi` groups. Everything under `/lupus/ngi` will be owned by `ngi-sw`, except the `/db` and `/log` dirs which are owned by `ngi`. Only deployers can write new programs and configs, but all NGI functional accounts (`funk_004`, `funk_006` etc) can write log files, to the SQL databases, etc. 

Three manual steps are also needed for each func account. In respective `~/.bashrc` the following snippet needs to be added: 

	# Enter the ngi_pipeline working environment
	source /lupus/ngi/conf/sourceme_<site>.sh
	source activate NGI

where `<site>` should be `upps` for `funk_004', and `sthlm` for `funk_006`. 

Then to get the crontab for each func account loaded a manual `crontab /lupus/ngi/conf/crontab_<site>` needs to be run. The crontab files includes an autoreload, so next time a new version of the crontab is deployed the crontab for the func account should after a while be appropriately reloaded. 

Finally each func account needs to create the ngi_pipeline dirs for logs and dbs in respective project area. The `funk_004` user should e.g run `/lupus/ngi/resources/create_ngi_pipeline_dirs.sh ngi2016001`.

## Note on re-compiling software

FIXME: Need to remove the file that is specified in the task's `creates=` field. Otherwise the compile step will be ignored.  
