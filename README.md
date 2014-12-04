Intro
=====

This is an example of using Docker images to host an entire build server infrastructure.

## Fig File overview

We create a build slave image that has node and maven installed

We spool up a copy of the Jenkins Docker image

We Spool up a Selenium environment using the Selenium Docker Images
 - 'nodes' for Chrome, Firefox with VNC access enabled (password: 'secret')
 - Selenium 'hub' to manage the nodes

Configuration
=============

In order for Jenkins to be able to use a slave, the public key for Jenkins needs to be configured on the machine

As the user that will run the Fig scripts:

* Create a directory called `~/jenkins_home`
* Generate an SSH key
    - `keygen -t rsa -C 'jenkins@example.com'`
    - When prompted, save the files to `~/jenkins_home/.ssh/id_rsa`
* Copy `~/jenkins_home/.ssh/id_rsa.pub` to `slave/ssh/authorized_keys`

Now when the image gets built the slave will trust incoming ssh connections from Jenkins

## Jenkins config

Because we're using a stock Jenkins Docker image, none of your command line build tools will be available to the slaves
running on 'master'.  You'll need to disable them and configure two new slaves.

### Add the Docker Slaves

The 2 docker slaves respond to SSH requests on port 2022 and 2122 respectively.  If you're running boot2docker, they
will be accessible at `192.168.59.103`

TODO: These should be accessible on localhost,  figure out why it's not working.


### Git 

Remember that Git is not installed on Jenkins by default.  Go in and add the 'Git Plugin' and restart Jenkins


