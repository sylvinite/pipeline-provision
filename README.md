# Deployment playbooks for NGI-Pipeline and related software (Piper, TACA, Tarzan, etc.) 



Ansible playbooks to deploy production instances on Irma from irma3. 

## Enabling the functionality of this repo

Checkout this repo to `/lupus/ngi/irma3/deploy`

Copy the file `bootstrap/bashrc` to `/lupus/ngi/irma3/bashrc`. This file has to be sourced every time a user wants to work. 

Setup a virtual enviroment, i.e: `/lupus/ngi/irma3/virtualenv-15.0.0/virtualenv.py -p /usr/bin/python2.7 /lupus/ngi/irma3/ansible-env`

Activate the environment `source /lupus/ngi/irma3/ansible-env/bin/activate` 

Install ansible `pip install ansible`

Download Anaconda and install it to `/lupus/ngi/sw/anaconda`

Enable rsync functionality `pip install pexpect`

## Developing new deployment scripts
### Irma 3
`source /lupus/ngi/irma3/bashrc` loads environment variables and sets GID to ngi-sw

`source /lupus/ngi/irma3/ansible-env/bin/activate` loads python enviroment, for ansible and `sync.py`

Write deployment scripts under `/lupus/ngi/irma3/deploy`. Make sure the target is somewhere under `/lupus/ngi/`.
Some folders (such as `/lupus/ngi/irma3/`) should not be used as targets as they are never rsynced.

Run the deployment script, for instance `ansible-playbook install.yml`

Place any additional files that need to be synced over under `/lupus/ngi/`

`python sync.py <remote dest>` rsyncs all files under `/lupus/ngi` on irma3 to irma1. Default directory is `/lupus/ngi`


## Running the supported tools

### Irma 1
`source /lupus/ngi/conf/sourceme_<SITE>.sh` where `<site>` is `upps` for `funk_004`, and `sthlm` for `funk_006` respectively.

`source activate NGI` to start the enviroment.

The run software in accordance with how it is typically is used.

#### Single use commands
`crontab /lupus/ngi/conf/crontab_<site>` (user) initializes the first instance of cron for the user. No posterior loading is required.

`/lupus/ngi/resources/create_ngi_pipeline_dirs.sh <project_name>` (project) creates the log and db directories for <project_name>.

`/lupus/ngi/sw/piper/gen_GATK_ref.sh` (global) generates the required GATK indexes to run piper.

## Pipeline integrity verification

`source /lupus/ngi/conf/sourceme_<SITE>.sh` where `<site>` is `upps` for `funk_004`, and `sthlm` for `funk_006` respectively.

`source activate NGI` to start the enviroment.

`python NGI_pipeline_test.py create --fastq1 <R1.fastq.gz> --fastq2 <R2.fastq.gz> --FC 1` creates a simulated flowcell.

Run `ngi_pipeline_start.py` with the commands `organize flowcell`, `analyze project` and `qc project` to organize, analyze and qc the generated data respectively.

## Pipeline run-time dependecies

- A working connection to `charon` or `charon-dev` as well as a generated API token. 

- A valid GATK key placed under `/lupus/ngi/irma3/deploy/files`. The filename must be specified in the `gatk_key` variable in `host_vars/127.0.0.1/main.yml`. 

- A `charon_credentials.yml` file placed under `/lupus/ngi/irma3/host_vars/127.0.0.1/` to set the variables `charon_base_url`, `charon_api_token_upps` and `charon_api_token_sthlm`.

- (Stockholm) A valid statusdb.yaml credentials file placed under `/lupus/ngi/deploy/files` to let NGI_Reports connect to StatusDB

## File details

Global configuration values set in `host_vars/127.0.0.1/main.yml`, and each respective role's in the `<role>/defaults/main.yml` file. 

`/lupus/ngi/irma3/log/ansible.log` logs the files installed by ansible

`/lupus/ngi/irma3/log/rsync.log` logs the rsync history

All directories need to be set to setgid=ngi-sw, with the exception of the files under `/lupus/ngi/sw/anaconda` as it breaks the enviroment.

When developing roles make sure that directories must have the setgid flag `mode=g+s`; this makes sure the files in the dirs (`ngi-sw` or `ngi`) recieve their correct owner.

Deploying to sw requires the deployer needs to be in both the `ngi-sw` and the `ngi` groups. Everything under `/lupus/ngi` is owned by `ngi-sw`, except the `/db/` and `/log/` dirs which are owned by `ngi`.

Only deployers can write new programs and configs, but all NGI functional accounts (`funk_004`, `funk_006` etc) can write log files, to the SQL databases, etc. 
