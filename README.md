# Deployment playbooks for NGI-Pipeline and related software (Piper, TACA, Tarzan, etc.) 

The NGI pipeline is deployed on Irma using ansible playbooks. Ansible playbooks are scripts written for easily adaptable automated deployment. The ansible playbooks are stored here.

## Deployment of the Ansible environment

Clone the repository to `/lupus/ngi/irma3/deploy`

Copy the file from the repository under `bootstrap/bashrc` to `/lupus/ngi/irma3/bashrc` 

Run `source /lupus/ngi/irma3/bashrc` this file has to be sourced for virtually any operation relating to this repository.

Setup a virtual environment, i.e: `/lupus/ngi/irma3/virtualenv-15.0.0/virtualenv.py -p /usr/bin/python2.7 /lupus/ngi/irma3/ansible-env`

Activate the environment using source `/lupus/ngi/irma3/ansible-env/bin/activate`

Install ansible with `pip install ansible`

Download Anaconda and install it to `/lupus/ngi/sw/anaconda`

Manually set Anaconda's permissions with `chmod -R g+rwX,o+rX /lupus/ngi/sw/anaconda`

Enable rsync functionality by using `pip install pexpect`

##Deployment of the NGI pipeline

###Requirements
The following files need to be present on irma3 in order to successfully deploy a working version of NGI pipeline:

- A working connection to charon or charon-dev as well as a generated API token. 

- A valid GATK key placed under `/lupus/ngi/irma3/deploy/files`. The filename must be specified in the gatk_keyvariable in `host_vars/127.0.0.1/main.yml`. 

- A `charon_credentials.yml` file placed under `/lupus/ngi/irma3/host_vars/127.0.0.1/` listing the variables `charon_base_url`, `charon_api_token_upps` and `charon_api_token_sthlm`

- A valid `statusdb.yml` access file placed under `/lupus/ngi/irma3/deploy/files`. Necessary layout is described at https://github.com/SciLifeLab/statusdb

###Typical deployment

Clone the repository to `/lupus/ngi/irma3/devel` and develop your scripts.

Create your own virtual environment for developing, i.e: `conda create -n myVenv python=2.7`

Alter `{{ ngi_pipeline_venv }}` under `host_vars/127.0.0.1/main.yml` to match your environment's name.

Once the features have been approved, `git pull` them into `/lupus/ngi/irma3/deploy`

Make sure the target is somewhere under `/lupus/ngi/`. Some folders (currently only `/lupus/ngi/irma3/` and 
`/lupus/ngi/resources/piper/gatk_bundle`) should not be used as targets as they are set up to be ignored by the rsync.

Run the deployment script, for instance `ansible-playbook install.yml`

Manually place any additional files that need to be synced over under `/lupus/ngi/`

If you don't want your environment synced to irma1, remove it.

Run `python sync.py <remote dest>` to rsync all files under `/lupus/ngi/` from irma3 to irma1. If no directory is given the default is `/lupus/ngi/`

###Manual initiations on irma1

Run `crontab /lupus/ngi/conf/crontab_<site>` once per user to initialize the first instance of cron for the user. No posterior loading is required.

Run `/lupus/ngi/resources/create_ngi_pipeline_dirs.sh <project_name>` once per project (i.e. ngi2016003) to create the log and db directories for NGI pipeline.

Run `/lupus/ngi/sw/piper/gen_GATK_ref.sh` one time ever to generate the required GATK indexes to run piper.

###Quick integrity verification

Run `source /lupus/ngi/conf/sourceme_<SITE>.sh` where <site> is upps to initialize variables funk_004, and sthlm to initialize funk_006 variables respectively.

Run `source activate NGI` to start the environment.

`python NGI_pipeline_test.py create --fastq1 <R1.fastq.gz> --fastq2 <R2.fastq.gz> --FC 1` creates a simulated flowcell.

Run `ngi_pipeline_start.py` with the commands `organize flowcell`, `analyze project` and `qc project` to organize, analyze and qc the generated data respectively.

###Other worthwhile information

Deploying to sw requires the deployer to be in both the `ngi-sw` and the `ngi` groups. Everything under `/lupus/ngi/` is owned by `ngi-sw`.

Only deployers can write new programs and configs, but all NGI functional accounts (funk_004, funk_006 etc) can write log files, to the SQL databases, etc.

Global configuration values are set in the repository under `host_vars/127.0.0.1/main.yml`, and each respective role's in the `<role>/defaults/main.yml` file. 

The log `/lupus/ngi/irma3/log/ansible.log` logs the files installed by ansible

The log `/lupus/ngi/irma3/log/rsync.log` logs the rsync history

All directories genereated from deployment need to be set to `setgid=ngi-sw` to properly function, with the exception of the files under `/lupus/ngi/sw/anaconda` as it breaks the environment.

When developing roles deployed directories must have the setgid flag mode=g+s; this makes sure the files in the dirs (ngi-sw or ngi) recieve their correct owner.
