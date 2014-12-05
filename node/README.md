# Selenium Grid Node - Firefox, Chrome, Debug

Selenium Node configured to run Firefox, Chrome, and remote Debug

An amalgam of the very useful [docker images maintained by SeleniumHQ](https://github.com/SeleniumHQ/docker-selenium/).

Where the SeleniumHQ images are intended to demonstrate large scale, parallel WebDriver testing, this image is intended
a demonstration of a small scale Continuous Integration environment running on a single headless VM.

## Rationale

In order to run Selenium tests on multiple User Agents, Selenium spins up multiple instances of xvfb, and if you
want the debug version, x11vnc as well.  In small scale testing it is common to run UI tests sequentially.  As your 
tests scale up typically you would scale your testing infrastructure to match.


