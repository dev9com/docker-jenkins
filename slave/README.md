Intro
=====

This is a Docker image configured to run as a Jenkins slave.

It installs JDK 7, and the latest Node.js and Maven versions on Ubuntu

It can be run as part of the 'Jenkins in a Box' Fig configuration (see [parent Readme](../README.md)) or run independently.

Configuration
=============

In order for Jenkins to be able to use a slave, the public key for Jenkins needs to be configured on the machine

* Log into the Jenkins Server
* Find or create the 'jenkins' user public key `/var/jenkins_home/.ssh/id_rsa.pub`
* Copy it to `ssh/authorized_keys`
* Build the image
* Run the image
* Configure a new node in Jenkins, with the SSH port of the running slave image

### Building the image

    docker build -t my_jenkins_slave:latest .

### Run the image

    docker run -p 2222:22 -dt my_jenkins_slave:latest
    
Add port 2222 (or whatever you'd like it to be) to the Advanced->Port field in the Node configuration



