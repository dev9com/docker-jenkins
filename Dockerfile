# Version: 0.0.1 1-Dev-2014
FROM ubuntu:latest
MAINTAINER Jason Marshall <username@users.noreply.github.com>

# update apt-get info
RUN apt-get update

# Install Java, Git, Maven, NPM
RUN apt-get install -y --no-install-recommends openjdk-7-jdk git maven nodejs npm
RUN apt-get clean

# Install an SSH server for jenkins slave
RUN apt-get install -y openssh-server
RUN mkdir -p /var/run/sshd

# jenkins user config 
RUN useradd -m --shell /bin/bash jenkins

ADD gitconfig /home/jenkins/.gitconfig
ADD ssh /home/jenkins/.ssh/
RUN chmod 600 /home/jenkins/.ssh/* 

RUN chown -R jenkins:jenkins /home/jenkins

# Setup Node

# Standard SSH port
EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
