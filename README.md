Intro
=====

This is an example of using Docker images to host an entire build server infrastructure.

## Fig File overview

We create a build slave image that has node and maven installed

We spool up a copy of the Jenkins Docker image

We Spool up a Selenium environment using the Selenium Docker Images
 - 'nodes' for Chrome, Firefox with VNC access enabled (password: 'secret')
 - Selenium 'hub' to manage the nodes

A more in-depth overview can be found in [the About file](ABOUT.md)

Configuration
=============

In order for Jenkins to be able to use a slave, the public key for Jenkins needs to be configured on the machine

As the user that will run the Fig scripts:

* Create a directory called `~/jenkins_home/.ssh`
* Generate an SSH key
    - `ssh-keygen -t rsa -C 'jenkins@example.com'`
    - When prompted, save the files to `~/jenkins_home/.ssh/id_rsa`
* Copy `~/jenkins_home/.ssh/id_rsa.pub` to `slave/ssh/authorized_keys`

Now when the image gets built the slave will trust incoming ssh connections from Jenkins

## Jenkins config

Because we're using a stock Jenkins Docker image, none of your command line build tools will be available to the slaves
running on 'master'.  You'll need to disable them and configure two new slaves.

### Add the Docker Slaves

The docker slave responds to SSH requests on port 2222.  If you're running boot2docker, it will be accessible at 
`192.168.59.103`

### Git 

Remember that Git is not installed on Jenkins by default.  Go in and add the 'Git Plugin' and restart Jenkins

### Boot2docker notes

If you want your Jenkins to be visible on the network, it's a good idea to shut down boot2docker, use the VirtualBox
administration console to turn on the 3rd ethernet interface and set it to the default (bridged).  This will cause the
host computer to have two IP addresses, one that routes straight to the VM.  This will save you from having to set up
port forwards for everything.
