Running Continuous Integration on a Shoestring with Docker and Fig
===============================================================

One of the things I love about Continuous Delivery (CD) is the "Show, don't Tell" aspect of the process.  While we can
often convince a customer or coworker what's the 'right thing to do', some people are harder to sell, and nothing beats
a demonstration.

The downside of Continuous Delivery is that, on the face of it, we use a lot of hardware.  Multiple copies of multiple
servers all doing nominally the same thing if you don't understand the system.  Cloud services are great for proving out
the system due to the low monthly outlay, but not all organizations allow it.  Maybe it's a billing issue, or concern
about your source getting stolen, or in an older company it may be a longstanding IT policy.  If a manager believes in
the system, they may be willing to stick their neck out and get paperwork signed or policies changed.  But how do you 
get them on board in the first place?  This chicken and egg problem has been bothering me for a while now, and Docker
helps a lot with this situation.

# Jenkins in a Box

The thing I wanted to know was, could I get a CI server and all of its dependencies into a set of Docker containers.  
It turns out not only is the answer 'yes', but most of the work has already been done for us.  You just have to wire
the right things together.

## Why start here?

The Big Ask for hardware starts with the build environment.

Continuous Delivery didn't always exist as a term.  Before that it was just a concept.  You start with a repeatable 
build. You automate compiling the code. You automate testing the code. You set up a build server so you know if it's
safe to pull down trunk/master in the morning.  You start enforcing clean builds of trunk/master.  You automate
packaging the code.  Then you automate archiving the packages.  One day you wake up and realize you have a self service
system where QA can pull new versions onto their test systems and from there it's a short leap to capturing 
configuration and doing the same thing in staging and production.  

But halfway through this process, you needed to do UI testing. For web apps that means Selenium. PhantomJS is a good 
starting point, but there are many things that only break on Firefox, or Chrome. Running a browser in a VM without a 
video card takes some special knowledge that not everybody has. And when the tests break you can't always reproduce
them locally. Sooner or later you need to watch the build server run the tests to get a clue why things aren't working.
Nothing substitutes for pixels.  Saucelabs can solve this for you but we're trying to start small.  

## The Plan

Most of what you need is out there, we just have to stitch it together.  The Jenkins team maintains Docker images.  
SeleniumHQ has their own as well, that can run Firefox and Chrome in a headless environment.  They also have 'debug' 
builds with support VNC connections, which we'll be using.  What we need is a Fig script to connect them to each other,
and the Jenkins slaves need our development toolchain. 

We need:
1. A Jenkins instance
1. A Selenium Grid (hub) to dole out browsers
1. Selenium 'nodes' which can run browsers
1. A Jenkins slave that can see the Selenium Grid
1. SSH Certs on the slave so that Jenkins can talk to it

### Caveats

Rather than modifying the Jenkins image, I opted to build a custom Jenkins Slave. Personally, I prefer not to run slaves
on the Jenkins box.  First, the hardware budget for the two is very different. Slaves are IO, memory, and CPU bound.  The
filesystem can be deleted between builds with few repurcussions.  The Jenkins server is a different beast.  It needs
to be backed up, it uses a lot disk space for artifacts (build statistics and test reports, even if you store your
binaries in a system of record), and it needs some bandwidth.  There are many ways for a bad build to take out the
entire server, and I would rather not even have to worry about it.  

Also it's probable you already have a Jenkins server, and it's easy enough to tweak this demo code to use it with your
existing server without impacting your current operations.  

## Fig to the rescue

Fig is a great Docker tool for wiring up a bunch of services to each other.  Since I know a lot of people who like to 
poke at the build environment, I opted to write a Fig file where all of the ports are wired to fixed port numbers on 
the host operating system.

You'll need to install Fig of course (it's not part of the Docker install, or at least not yet), and you'll need to
create a ~/jenkins_home directory which will contain all of the configuration for Jenkins, you'll need to generate an
SSH key for Jenkins, and copy it into `authorized_keys` for the slave (see the [README.md] if you need help with that
step).  Then you can just type in two magic little words:

    fig up

And after a few minutes of downloading and building images, You'll have a Jenkins environment running in a box.

You'll have the following running (substitute 192.168.59.103 if you're running boot2docker)
1. Jenkins on http://127.0.0.1:8080
1. A Jenkins slave listening for SSH connections on 127.0.0.1:2222
1. A virtual desktop running Firefox tests listening on 127.0.0.1:5950
1. A virtual desktop running Chrome tests listening on 127.0.0.1:5960
1. Selenium hub listening on port 4444 (behaving similarly to selenium-standalone)

## Further Improvements

If that's not already cool enough for you, there are some more steps I'll leave as an exercise for the reader.

### Go smaller: Single node

On small projects, it's not uncommon to run the Integration Tests sequentially.  A single browser open at a time, to
avoid any concurrent modification issues resulting in false build failures.  

I did an experiment where I took the SeleniumHQ chrome debug image, dropped firefox on it as well, and changed the
configuration to offer both browsers.  I run this version in [compact.yml] instead of the two run in the normal example.
This means only one copy of `X11` and `xvfb` is running, and you only need one VNC session to see everything.  The
trouble with this is ongoing maintenance.  I've done my best to create the minimum configuration possible, but it's
always a possibility that a new SeleniumHQ release won't be compatible.  For this reason I'd say this should only be
used for Phase 1 of a project, and should be a priority to eliminate this custom image ASAP.

    fig --file=compact.yml build
    fig --file=compact.yml up
    
This version of the system peaked at a little under 4 GB of RAM.  With developer grade machines frequently having 16GB
of RAM or more this becomes something you could actually run on someone's desktop for a while.  Or you could split it 
and run it on 2 machines.

### Go bigger: Parallel tests

One of the big reasons people run Selenium Grid is to run tests in parallel. One cool thing you can do with Fig is tell
it "I want you to run 4 copies of this image" by using the `fig scale` command, and it will spool them up.  The tradeoff
is that at present it doesn't have a way to deal with fixed port numbers (there's no support for port ranges) so you
have to take out the port mappings (eg: "5950:5900" becomes "5900").  The consequence is that every time you restart
Fig, the ports tend to change. But watching a parallel test run over VNC would be challenging to say the least, in which
case you might opt to not run VNC at all.  In that case you can save some resources by using the non-debug images 




# Examples and Further reading

[fig.yml](fig.yml)

[compact.yml](compact.yml)

[Selenium HQ Docker](https://github.com/SeleniumHQ/docker-selenium)

[Jenkins images in the Docker Registry](https://registry.hub.docker.com/_/jenkins/)