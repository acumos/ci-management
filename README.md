# Continuous Integration for Acumos at LF

This repository has templates that generate jobs in the Linux Foundation Jenkins instance
using the Jenkins Job Builder. For more information about that tool please see:

    https://docs.openstack.org/infra/system-config/jjb.html

## Template design

Jenkins jobs are generated from standard Global JJB templates and from custom-to-project
JJB templates.

## Software Prerequisites

The following software packages are needed to build Acumos components. These are installed on Jenkins build minions:

- Docker version 1.13+
- Java version version 1.8
- Maven version version 3+
- Python versions 3.4, 3.5, 3.6, 3.7
- Protocol buffers compiler (protoc) version 3.5.1+

### Global JJB templates

Global JJB jobs originated with the Open Daylight project and reflect CI/CD design choices
made there. Global JJB templates are used as much as possible in Acumos. As of this writing
this includes CLM, RST/RTD documentation, javadoc, simple Maven/Java jar jobs and some Python
jobs.

Documentation of Global JJB templates can be found here:

    http://global-jjb.releng.linuxfoundation.org/en/latest/index.html

#### Docker issues

As of this writing Global JJB templates provide no support for use of a Docker Maven plugin.
The Global JJB templates assume all resources will be pulled from network resources such
as the Nexus2 jar repository first. In Acumos it makes little sense to deploy Spring-repackaged
super jars of 50+ MB each that are not intended for public consumption.

### Custom JJB templates for Java + Docker projects

Acumos has multiple projects that build a jar then wrap it into a docker image using a Maven
plugin, with no need to deploy that jar. Acumos also has projects that build a jar and/or a
Docker image and need to deploy the jar. Custom JJB templates are used for Java/Maven verify,
build and release jobs on all of these projects. The custom templates are derived from the
Global JJB templates of similar names. A significant change is adding invocation of a "builder"
(aka shell script) that obtains Nexus3 docker registry credentials and logs in at the
nexus3.acumos.org registry. With that prerequisite met, the Maven docker plugin succeeds in
pulling and pushing images.

A Java project that includes a docker build and push action should use these jobs in its
project.yaml file::

    jobs:
      - gerrit-maven-dl-verify
      - gerrit-maven-dl-merge
      - gerrit-maven-dl-stage

A Java project that includes a docker build and push action, but does NOT publish any
jar or pom file for deployment, should use these jobs in its project.yaml file::

    jobs:
      - gerrit-maven-dl-verify
      - gerrit-maven-dl-nd-merge
      - gerrit-maven-dl-nd-stage

Note that the same verify job is used in both scenarios.

## Testing the templates

These instructions explain how to test the Acumos templates using the Jenkins sandbox.
This catches errors before submitting the changes as Gerrit reviews. Prerequisites:

Install the Jenkins job builder:

    pip install --user jenkins-job-builder

Check out the global JJB templates submodule within this repo:

    git submodule update --init

### Test Locally

Check sanity by running the Jenkins job-builder script in this directory:

    jenkins-jobs test -r jjb

### Deploy the templates to the Jenkins sandbox

Login (after requesting membership in group acumos-jenkins-sandbox-access) at the Jenkins sandbox:

    https://jenkins.acumos.org/sandbox

Get the authentication token from the sandbox:
a) click on your user name (top right)
b) click Configure (left menu)
c) click API Token (button)

Create a config file jenkins.ini using the following template and your credentials
(user name and API token from above):

    [job_builder]
    ignore_cache=True
    keep_descriptions=False
    recursive=True

    [jenkins]
    query_plugins_info=False
    url=https://jenkins.acumos.org/sandbox
    user=YOUR-USER-NAME
    password=YOUR-API-TOKEN

Build and deploy a specific job using the EXACT job name.

    jenkins-jobs --conf jenkins.ini update jjb your-job-name-here

Examples:

    jenkins-jobs --conf jenkins.ini update jjb acumos-python-client-tox-verify-master

    jenkins-jobs --conf jenkins.ini update jjb common-dataservice-maven-dl-verify-master-mvn33-openjdk8

In the sandbox visit the job page, then click the button "Build with parameters" in left menu.

### How to build from a Gerrit review branch

This explains how to launch a "verify" job in the Sandbox on an open review.
Most "verify" jobs accept parameters to build code in a review submitted to
Gerrit. You must specify the change ref spec, which is a Git branch name.
Get this by inspecting Gerrit's "download" links at the top right. The branch
name will be something like this:

    refs/changes/78/578/2

The first number is a mystery to me; the second number is the Gerrit change number;
the third number is the patch set within the change.

Enter this name for both the GERRIT_BRANCH and the GERRIT_REFSPEC parameters, then
click Build.
