---
date: 
  created: 2023-12-29
  updated: 2025-08-24
authors:
  - pat
categories:
  - quick-start
tags:
  - ansible
---
# Ansible Navigator: Beginner's Guide
Ansible Navigator is a new way to use familiar Ansible tools.
Tools like ansible-playbook, ansible-inventory, and ansible-doc are just some examples of what Navigator can do as a comprehensive, all-in-one tool. 

<!-- more -->
The purpose of Ansible Navigator is to enable running playbooks within execution environments, the same way that Ansible Automation Platform runs jobs inside them. This functionality means you can now develop and test your playbooks in the same environment you would be running in production.

This article gets you started with Navigator - we'll explore more of its features in upcoming posts.

## Prerequisites
You should have the following installed on your system:

- Either Podman or Docker
- Python
- pip

!!! note
    Red Hat subscribers can install Navigator via RPM packages, but this guide focuses on the pip installation method.

### Installation
We will install Ansible Navigator using `pip`, the Python package manager.
We will install it in a Python virtual environment to isolate the installation and prevent potential conflicts with system packages. 

Create and activate a virtual environment:
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

pip install ansible-navigator
```

## Exploring ansible-navigator

With ansible-navigator installed you can run it by typing:


```
❯ ansible-navigator
-------------------------------------------------------------------------------------
Execution environment image and pull policy overview
-------------------------------------------------------------------------------------
Execution environment image name:     ghcr.io/ansible/community-ansible-dev-tools:latest
Execution environment image tag:      latest
Execution environment pull arguments: None
Execution environment pull policy:    tag
Execution environment pull needed:    True
-------------------------------------------------------------------------------------
Updating the execution environment
-------------------------------------------------------------------------------------
Running the command: podman pull ghcr.io/ansible/community-ansible-dev-tools:latest
[... container download output ...]
```

The first time you run it, it will download a community-ansible-dev-tools container as shown above.

Once that't done you will see the following screen:
![Ansible Navigator](/assets/images/ansible-navigator.png)

You can see from the list that some tools incorporated into ansible-navigator are ansible-doc, ansible-playbook, and ansible-inventory. For now, let's look at the images option.

Before we do that let's exit out and download the homelab-ee that is an evolution of the execution environment I made in the article, [Ansible Builder]( ansible_builder_intro.md ), by doing a podman pull.

Now let's reopen ansible-navigator and go to the images section. You do that by typing a colon followed by the option you want, so in our case `:images`.

![Images](/assets/images/images.png)


We have two container images on our system, as shown above. The default image is the creator-ee; we will look at one way to change that later. It also tells us if the container images we have on our system are usable as execution environments.

Let's examine homelab-ee; you do that by pressing the number next to the image name, in our case, 1.

![Image Info](/assets/images/image_info.png)

It shows the image name at the top and gives us more choices. Let's look at info about Ansible and Python packages installed in the execution environment. You can select "Ansible version and collections" by pressing 2.

![Ansible Info](/assets/images/ansible_info.png)

Here, we can see all the collections and the version of Ansible installed in the execution environment.

Let's look at one more option. Hitting 'esc' takes us back one page and then let's select "Python packages" by hitting 3.

This gives us a list of all the Python packages installed on the system. If we use the up and down cursor keys it scrolls through the list, in this case there are 71 Python packages installed in the image. An interesting one to note is the *proxmoxer* package #37 which was installed in the execution environment to be albe to run the proxmox modules.

I will leave the rest of the options under images up to you to explore.
![Python packages](/assets/images/python_packages.png)


### Configuring Ansible Navigator
First lets see what kind of options we have, let's run:

`ansible-navigator --help`

```
$ ansible-navigator --help
Usage: ansible-navigator [options]

Options (global):
 -h     --help                                   Show this help message and exit
 --version                                       Show the application version and
                                                 exit
[... additional configuration options ...]
Subcommands:
 {subcommand} --help
  builder                                        Build [execution environment]
                                                 (https://ansible.readthedocs.
                                                 io/en/latest/getting_started_
                                                 ee/index.html) (container
                                                 image)
[... additional configuration subcommands ...]
# Full options and subcommands are very long
```
There are numerous options and subcommands available for Ansible Navigator. Run this yourself to see the whole list. Let's take a look at the help page for the `settings` subcommand.

```
$ ansible-navigator settings --help
Usage: ansible-navigator settings [options]

settings: Review the current ansible-navigator settings

Options (global):
 -h     --help                                   Show this help message and exit
 --version                                       Show the application version and
                                                 exit
[... additional configuration options ...]

Options (settings subcommand):
 --se   --effective                              Show the effective settings.
                                                 Defaults, CLI parameters,
                                                 environment variables, and the
                                                 settings file will be combined
 --gs   --sample                                 Generate a sample settings file
 --ss   --schema                                 Generate a schema for the settings
                                                 file ('json'= draft-07 JSON
                                                 Schema) (json) (default: json)
 --so   --sources                                Show the source of each current
                                                 settings entry
```

Let's look at the option `--gs`, which generates a sample Navigator configuration with all options commented out.

```
$ ansible-navigator settings --gs
---
ansible-navigator:
#   ansible:
#     config:
#       # Help options for ansible-config command in stdout mode
#       help: False
#       # Specify the path to the ansible configuration file
#       path: ./ansible.cfg
#   # zone
[... additional configuration ...]
#   time-zone: UTC
```
Here you can set all kind of options, if you look under `execution-environment` you can see how we specify `image` the default image used by ansible-navigator. 
In this case its the creator-ee that navigator downloaded when we first started it up. Let's make that our homelab-ee.

>**Ansible Navigator config locations checked**
>
>First match is used(this may change in future releases):
>
>|
>|----------------------------------------|-----------------------------------------|
>| ANSIBLE_NAVIGATOR_CONFIG               | env variable                            |
>| ./ansible-navigator.\<ext\>            | No dot at begining of the file name, this is in the project directory |
>| ~/.ansible-navigator.\<ext\>           | Dot at the beginning of the file name, this is in the user home directory |
>
>__\<ext\> can be either yaml/yml or json debending on what format the file is in.__

In our local directory we will add an ansible-navigator.yml file and add our custom ee.
```
---
ansible-navigator:
  execution-environment:
    image: registry.patsbytes.net/homelab-ee:latest
```

Running ansible-navigator and selecting images we see that our image is now default:

![homelab-ee default](/assets/images/homelab-ee_default.png)

As we wrap up this intro to Ansible Navigator, you now know how to install and perform basic configuration. Watch for future articles where we'll dive deeper into other parts of Ansible Navigator. Until then, happy automating, and stay tuned for more insights and guides!

### References and further reading:

Ansible Navigator documentation:  
<https://ansible.readthedocs.io/projects/navigator/>

Installing Ansible Navigator:  
<https://ansible.readthedocs.io/projects/navigator/installation/>

Installing Packages: (Python)  
<https://packaging.python.org/en/latest/tutorials/installing-packages/>

Ansible Navigator settings:  
<https://ansible.readthedocs.io/projects/navigator/settings/>
