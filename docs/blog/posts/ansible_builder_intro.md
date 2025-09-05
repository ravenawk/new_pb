---
date: 
  created: 2023-06-30
  updated: 2025-08-26
authors:
  - pat
categories:
  - QuickStart
tags:
  - ansible
---
# Ansible Builder: A Beginners Guide

## What is Ansible Builder

Ansible Builder enables you to build and customize execution environments, creating reproducible environments tailored to your specific work needs.
These environments ensure consistent and reproducible execution of playbooks and roles by providing a known environment. 

<!-- more -->
Execution environments in Ansible refer to container images that include all the necessary dependencies, modules, and plugins to execute Ansible automation.

## Prerequisites
You must have the following installed on your system:

- Either Podman or Docker
- Python
- pip

## Installation
We will install using `pip`, the Python package manager. 
We'll install it in a Python virtual environment to isolate the installation and prevent potential conflicts with system packages. 
(You can alternatively install it from Red Hat repositories if you have a Red Hat subscription.)


Create and activate a virtual environment:
```bash
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

`pip install ansible-builder`
``` 


## Building an Execution Environment for Proxmox
### Creating the Build Files

Let's use Ansible Builder to build an execution environment for managing Proxmox servers. Proxmox VE is an open-source virtualization platform similar to VMware vSphere.

While you can include various files in your execution environment build, the core file is `execution-environment.yml`.

```yaml title="execution-environment.yml"
---
version: 3

images:
  base_image:
    name: quay.io/ansible/awx-ee:latest

dependencies:
  ansible_core:
    package_pip: ansible-core==2.14.0
  ansible_runner:
    package_pip: ansible-runner
  galaxy:
    collections:
      - community.general
  python:
    - proxmoxer
    - requests
  system:
    - gcc
    - python3-devel
    - libxml2-devel

additional_build_files:
  - src: ansible.cfg
    dest: configs

additional_build_steps:
  prepend_final:
    - ADD _build/configs/ansible.cfg /etc/ansible/ansible.cfg

options:
  package_manager_path: /usr/bin/dnf
```

The above `execution-environment.yml` has all the Ansible, Python, and system requirements in line. 
You can also specify them as separate files, such as `requirements.yml` (Ansible) and `requirements.txt` (Python).


```yaml title="Using seperate files"
--snip--
dependencies:
  ansible_core:
    package_pip: ansible-core==2.14.0
  ansible_runner:
    package_pip: ansible-runner
  galaxy: requirements.yml
  python: requirements.txt
  system: bindep.txt
--snip--
```


!!! note "Requirements"
    When building an execution environment, the final image requires both Ansible Core and Ansible Runner - this can be pre-installed in the base image or added during the build process, as shown above.

I have included an empty `ansible.cfg` here to show how you include it in your image build. 
Feel free to put any options in this file that you want to use in your execution environment. 
Our `execution-environment.yml` will put this in the container image where we specify. 
We will look more at this later on.

!!! note "Possible gotchas"
    When I first wrote this article, the build process didn’t require any additional RPMs, and I had to call out `microdnf` as the package manager explicitly (it handles some RPM installs even if you don’t request extra packages). In the current version, the build looks for `microdnf` by default, but awx-ee now includes `dnf`. Because of this, I had to adjust the steps above to get everything working again. I’m calling this out since these details may continue to change in future releases.

When the files are ready, execute the following command:

`ansible-builder build -t proxmox-env`

`-t` tags the image that is created.

This is the message I see when running it:

```bash
Running command:
  podman build -f context/Containerfile -t promox-env context
Complete! The build context can be found at: /home/pmartin/ansible-builder/article/context
```

### Verifying the Build
After the build process finishes you should have the image available to use.

```bash
$ podman images
REPOSITORY              TAG         IMAGE ID      CREATED        SIZE
localhost/proxmox-env   latest      0ce7182e8bab  4 minutes ago  1.58 GB
---snip---
```

Let's look at the collections using podman.

```bash title="Execution environment collections"
$ podman run localhost/proxmox-env ansible-galaxy collection list

# /usr/share/ansible/collections/ansible_collections
Collection              Version
----------------------- -------
amazon.aws              9.4.0  
ansible.posix           2.0.0  
ansible.windows         2.8.0  
awx.awx                 24.6.1 
azure.azcollection      3.3.1  
community.general       11.2.1 
community.vmware        5.5.0  
google.cloud            1.5.1  
kubernetes.core         5.2.0  
kubevirt.core           2.1.0  
openstack.cloud         2.4.1  
ovirt.ovirt             3.2.0  
redhatinsights.insights 1.3.0  
theforeman.foreman      5.3.0  
vmware.vmware           1.11.0 
```

For comparison this is a list of the collections that were already in the container we used as a base image.

```bash title="Collections in base image"
$ podman run quay.io/ansible/awx-ee ansible-galaxy collection list

# /usr/share/ansible/collections/ansible_collections
Collection              Version
----------------------- -------
amazon.aws              9.4.0  
ansible.posix           2.0.0  
ansible.windows         2.8.0  
awx.awx                 24.6.1 
azure.azcollection      3.3.1  
community.vmware        5.5.0  
google.cloud            1.5.1  
kubernetes.core         5.2.0  
kubevirt.core           2.1.0  
openstack.cloud         2.4.1  
ovirt.ovirt             3.2.0  
redhatinsights.insights 1.3.0  
theforeman.foreman      5.3.0  
vmware.vmware           1.11.0 
```

The base image included a lot of collections already. But for our custom execution environment, it needed the 'community.general' collection, which contains the proxmox module.

## Using our Execution Environment
We have the collection we need for working with proxmox, now, let's test it. We will be using ansible-navigator to execute the playbook using our execution environment. A future article will go deeper into ansible-navigator.

This is the simple playbook we will be running.

```yaml title="Create vm from list"
---
- hosts: localhost
  connection: local
  vars_files:
    - vault.yml
  tasks:
    - name: Create vms from a list
      community.general.proxmox_kvm:
        api_user: "{{ api_user }}"
        api_password: "{{ api_password }}"
        api_host: "{{ api_host }}"
        validate_certs: false
        clone: rh8-tmplt
        name: prox-ee-test
        node: pve
        storage: Local_lun
        timeout: 300

```
Here is the playbook run.

```bash
ansible-navigator run --eei localhost/proxmox-ee clone_vm_proxmox.yml --pp=never -m stdout -i inventory

PLAY [localhost] ***************************************************************

TASK [Gathering Facts] *********************************************************
ok: [localhost]

TASK [Create vms from a list] **************************************************
changed: [localhost]

PLAY RECAP *********************************************************************
localhost                  : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

This article isn't about ansible-navigator, but here is what each of the option does. (You can find more details about Ansible Navigator [in this post.](ansible_navigator_intro.md))

| Option | Description |
|--------|-------------|
| run    | Runs a playbook |
| --eei  | What execution environment to use |
| --pp   | Pull policy, whether or not to pull the image |


After the playbook run if we check proxmox we see our vm.

![Proxmox vm](/assets/images/proxmox.png)

It works! Now we can share that execution environment with others and know that everyone is working in the same environment. Now let's go back and check one last thing.

When we ran the build command with ansible-builder it creates a directory, context, where it stores files used in the build.

```bash
context
├── _build
│   ├── bindep.txt
│   ├── configs
│   │   └── ansible.cfg
│   ├── requirements.txt
│   ├── requirements.yml
│   └── scripts
│       ├── assemble
│       ├── check_ansible
│       ├── check_galaxy
│       ├── entrypoint
│       ├── install-from-bindep
│       ├── introspect.py
│       └── pip_install
└── Containerfile

```

Some interesting files are the two requirement files and the bindep.txt - they contain exactly what you'd expect: Python modules, collections list, and system package list. You will also see our `ansible.cfg` has been copied into the `_build` directory along with a generated Containerfile that handles the actual creation of the image. 

Take some time to explore these copied and generated files - they reveal how ansible-builder translates your files into a working container image.

Ansible Builder is a tool for creating your own execution environments. By leveraging its capabilities to bundle dependencies, modules, and plugins, you can ensure consistent and reliable execution of your automation workflows. This article scratches the surface of what you can do. Be sure to check out the documentation for more options.

## References and further reading

Ansible Builder github:  
<https://github.com/ansible/ansible-builder>

Installing Packages: (Python)  
<https://packaging.python.org/en/latest/tutorials/installing-packages/>

Proxmox:  
<https://proxmox.com/en/>

Ansible Navigator github:  
<https://github.com/ansible/ansible-navigator>

[Ansible Navigator](ansible_navigator_intro.md)
