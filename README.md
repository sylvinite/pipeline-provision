# Deployment playbooks for NGI-Pipeline and related software (Piper, TACA, Tarzan, etc.) 

The NGI pipeline is deployed on Irma using ansible playbooks. Ansible playbooks are scripts written for easily adaptable automated deployment. The ansible playbooks are stored here.

## Deployment of the Ansible environment

Clone the repository to `/lupus/ngi/irma3/deploy`

Copy the file from the repository under `bootstrap/bashrc` to `/lupus/ngi/irma3/bashrc` 

Run `source /lupus/ngi/irma3/bashrc` -- this file has to be sourced for virtually any operation relating to this repository.

Run `umask 0002` (or even more preferably add it to your ~/.bashrc file).

Setup a virtual environment, i.e: `/lupus/ngi/irma3/virtualenv-15.0.0/virtualenv.py -p /usr/bin/python2.7 /lupus/ngi/irma3/ansible-env`

Activate the environment using source `/lupus/ngi/irma3/ansible-env/bin/activate`

Install ansible with `pip install ansible`

Enable rsync functionality by using `pip install pexpect`

Install cpanm into the Ansible environment (which is already in $PATH) so that we can install Perl packages locally: 

```
cd /lupus/ngi/irma3/ansible-env/bin
curl -L https://cpanmin.us -o cpanm
chmod +x cpanm
```

##Deployment of the NGI pipeline

###Requirements
The following files need to be present on irma3 in order to successfully deploy a working version of NGI pipeline:

- A working connection to charon or charon-dev as well as a generated API token. 

- A valid GATK key placed under `/lupus/ngi/irma3/deploy/files`. The filename must be specified in the gatk_keyvariable in `host_vars/127.0.0.1/main.yml`. 

- A `charon_credentials.yml` file placed under `/lupus/ngi/irma3/deploy/host_vars/127.0.0.1/` listing the variables `charon_base_url_{stage,prod}`, `charon_api_token_upps_{stage,prod}` and `charon_api_token_sthlm_{stage,prod}`

- A valid `statusdb_creds.yml` access file placed under `/lupus/ngi/irma3/deploy/files`. Necessary layout is described at https://github.com/SciLifeLab/statusdb

- Valid SSL certificates for the web proxy under `/lupus/ngi/irma3/deploy/files` (see `roles/tarzan/README.md` for details) 

###Typical deployment

TODO: Come back and update these instructions later. 

Fork the repository https://github.com/NationalGenomicsInfrastructure/irma-provision to your private Github repo. Clone this private repository to `/lupus/ngi/irma3/devel` and develop your scripts in a new feature branch. 

Test deploy your roles/playbook changes with e.g. `ansible-playbook install.yml`. This will install your development run in `/lupus/ngi/irma3/devel-root/<username>-<branch_name>`. 

When you are satisfied with your changes you need to test it in staging. First create a pull request from your feature branch into upstream irma-provisioning's master branch. 

Once the feature has been approved, go to `/lupus/ngi/irma3/deploy` and do a 

```
    git checkout master 
    git pull 
		ansible-playbook install.yml -e deployment_environment=staging -e deployment_version=FOO
```

where `FOO` is a unique staging version you pick. This will install your run under `/lupus/ngi/staging/FOO` and symlink `/lupus/ngi/staging/latest` to it, for easier access. 

If you want to stage test many feature branches at the same time then for better log of what is included then it is recommended to do a Github tag and pre-release of the master branch ((https://github.com/NationalGenomicsInfrastructure/irma-provision/releases/new) instead of running `ansible-playbook` directly inside the master branch. Write a good release note so it is clear what significant things are included. 

So if you've e.g. created a pre-release called `v1.2-beta.6` go to `/lupus/ngi/irma3/deploy` and do a 

```
    git fetch --tags
		git checkout tags/v.1.2-beta.6
		ansible-playbook -e deployment_environment=staging
```

This will deploy everything under `/lupus/ngi/staging/v1.2-beta.6` and update the `latest` symlink accordingly. (The playbook will automatically pick the currently checkout tag as version name if we're deplying to staging or production, but it can be overriden by manually adding the `deployment_version` flag as seen in the `FOO` example above.) 

Run `python sync.py staging`  to rsync the staged environment from irma3 to irma1. 

Login to the Irma cluster as your personal user and then run `source /lupus/ngi/staging/latest/conf/sourceme_<site>.sh && source activate NGI` (where `site` is `upps` or `sthlm` depending on location). For convenience add to your personal file bash init file `~/.bashrc`. This will load the staging environment for your user with the appropriate staging variables set. 

When the staged environment has been verified to work OK (TODO: add test protocol, manual or automated sanity checks) proceed with making a production release. In our case we would therefore now create the tag and release called `v1.2.6`. 

We can now, still standing in `/lupus/ngi/irma3/deploy`, do a `git fetch --tags && git checkout tags/v1.2.6 && ansible-playbook install.yml -e deployment_environment=production`. This will install everything under `/lupus/ngi/production/v1.2.6` and the symlink `/lupus/ngi/production/latest` pointing to it. 

Run `python sync.py production` to rsync all files under `/lupus/ngi/production` from irma3 to irma1. 

####Nota bene

Remember that you will probably have to restart services manually after a new production release have been rolled out. First re-load the crontab as the func user on irma1 with a `crontab /lupus/ngi/production/latest/conf/crontab_SITE`. Then, depending on what software your func user is running, continue with manually shutting down the old versions and re-start the new versions of the software. 

###Manual initiations on irma1

Run `crontab /lupus/ngi/conf/crontab_<site>` once per user to initialize the first instance of cron for the user. No posterior loading is required.

Run `/lupus/ngi/resources/create_ngi_pipeline_dirs.sh <project_name>` once per project (i.e. ngi2016003) to create the log, db and softlink directories for NGI pipeline (and generate the softlinks).

Add `source /lupus/ngi/production/latest/conf/sourcme_<site>.sh && source activate NGI`, where `site` can be `upps` or `sthlm`, to each functional account's bash init file `~/.bashrc`. 

###Quick integrity verification

Run `source /lupus/ngi/conf/sourceme_<SITE>.sh` where <site> is upps to initialize variables funk_004, and sthlm to initialize funk_006 variables respectively.

Run `source activate NGI` to start the environment.

`python NGI_pipeline_test.py create --fastq1 <R1.fastq.gz> --fastq2 <R2.fastq.gz> --FC 1` creates a simulated flowcell.

Run `ngi_pipeline_start.py` with the commands `organize flowcell`, `analyze project` and `qc project` to organize, analyze and qc the generated data respectively.

###Other worthwhile information

Deploying requires the deployer to be in both the `ngi-sw` and the `ngi` groups. Everything under `/lupus/ngi/` is owned by `ngi-sw`.

Only deployers can write new programs and configs, but all NGI functional accounts (`funk_004`, `funk_006` etc) can write log files, to the SQL databases, etc.

Global configuration values are set in the repository under `host_vars/127.0.0.1/main.yml`, and each respective role's in the `<role>/defaults/main.yml` file. 

The log `/lupus/ngi/irma3/log/ansible.log` logs the files installed by ansible

The log `/lupus/ngi/irma3/log/rsync.log` logs the rsync history

When developing roles deployed directories must have the setgid flag `g+s`, and be created while the deployer had his gid set to `ngi-sw`. This ensures the files in the dirs recieve the correct group owner when they are created.
