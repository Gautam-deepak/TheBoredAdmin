#!/bin/bash
# Proof of concept of running playbooks in AWX and recording them in ARA
# From a vanilla CentOS8 image: https://cloud.centos.org/centos/8/x86_64/images/CentOS-8-GenericCloud-8.1.1911-20200113.3.x86_64.qcow2

# Add local bin directory to PATH so we can use things installed with "pip install --user"
export PATH=$PATH:~/.local/bin

dnf -y update

# Install Ansible and Python3
dnf -y install epel-release
dnf -y install ansible python3

# Install docker and docker-compose
dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
dnf install -y docker-ce --nobest
systemctl enable docker --now
python3 -m pip install docker-compose --user

# Install git, retrieve AWX and install it
dnf install -y git
git clone https://github.com/ansible/awx
pushd awx
sed -i 's,ansible_python_interpreter.*$,ansible_python_interpreter="/usr/bin/env python3",' installer/inventory
ansible-playbook -i installer/inventory installer/install.yml
popd

# Install the ARA callback plugin in the awx_task container
docker exec -it awx_task /var/lib/awx/venv/ansible/bin/pip install ara

# Install the ARA API server on the container host server and run SQL migrations
python3 -m pip install ara[server] --user
ara-manage migrate

# Get path to ARA's callback plugin (ex: /var/lib/awx/venv/ansible/lib/python3.6/site-packages/ara/plugins/callback )
docker exec -it awx_task /var/lib/awx/venv/ansible/bin/python3 -m ara.setup.callback_plugins

# Edit ~/.ara/server/settings.yaml to add local IP address to ALLOWED_HOSTS
# If you want to access the ARA built-in web interface from a browser, the
# public hostname or IP address of the server also needs to be added to ALLOWED_HOSTS
# vi ~/.ara/server/settings.yaml

# Launch an API server in the foreground
# ara-manage runserver 0.0.0.0:8000

# Login to the AWX interface and go to Settings -> Jobs
# Add the callback plugin path retrieved in the previous step to the "ANSIBLE CALLBACK PLUGINS" box
# At the bottom in "EXTRA ENVIRONMENT VARIABLES" set the following:
# - ARA_API_CLIENT to "http"
# - ARA_API_SERVER to your API server endpoint ( ex: http://10.0.0.10:8000 )

# In the AWX UI, go in Projects and run a sync on the Demo project
# In the AWX UI, go in Templates and run the Demo Job Template

# Data should've been recorded in ARA and available through the built-in API server interface.
# If you get a HTTP 400 Bad Request error, ensure the hostname you are trying to use is in ALLOWED_HOSTS