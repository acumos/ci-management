# Continuous Integration for Acumos at LF

This repository has templates that generate jobs in the Linux Foundation Jenkins instance
using the Jenkins Job Builder.  For more information about that tool please see:

    https://docs.openstack.org/infra/system-config/jjb.html

## Template design

Acumos jobs are generated from standard Global JJB templates and from custom-to-project
templates.

## Software Prerequisites

The following software packages are needed to build Acumos components. These are installed on Jenkins build minions:

* Docker version 1.13+
* Java version version 1.8
* Maven version version 3+
* Python versions 3.4, 3.5, 3.6
* Protocol buffers compiler (protoc) version 3.5.1+

### Global JJB templates

Global JJB jobs originated with the Open Daylight project and reflect CI/CD design choices
made there.  Global JJB templates are used as much as possible in Acumos. As of this writing
this includes CLM, RST/RTD documentation, javadoc, simple Maven/Java jar jobs and some Python
jobs.

Documentation of Global JJB templates can be found here:

    http://global-jjb.releng.linuxfoundation.org/en/latest/index.html

#### Docker issues

As of this writing Global JJB provides no support for use of a Docker Maven plugin.
The Global JJB docker jobs assume all resources will be pulled from network resources such
as the Nexus2 jar repository first. In Acumos it makes little sense to deploy Spring-repackaged
super jars of 50+ MB each that are not intended for public consumption.

### Custom JJB templates for Java + Docker projects

Acumos has multiple projects that build a jar then wrap it into a docker image using a Maven
plugin.  Custom JJB templates are used for Java/Maven verify, build and release jobs on these
projects.  The custom templates are derived from the Global JJB templates of similar names. 
The primary change is adding invocation of a "builder" (aka shell script) that obtains Nexus3
docker registry credentials and logs in at the nexus3.acumos.org registry.  With that prerequisite
met, the Maven docker plugin succeeds in pulling and pushing images.

### Custom JJB templates for Python library projects

A Python library project can be configured to publish artifacts to Nexus3 PyPI repositories
at the Linux Foundation and the global PyPI index.  Add these jobs to the project YAML file:

    jobs:
      - '{project-name}-python-staging-{stream}'
      - '{project-name}-python-release-{stream}'

The python-staging job build the project and pushes the build artifacts to an index named
"PyPi.staging" in the Linux Foundation's Nexus3 repository.  This job is triggered on every
Gerrit merge event.  In case of failure, this job can also be triggered manually by posting
a comment "remerge" (like every other merge job) in the appropriate Gerrit review request.
If the same version of the artifact already exists in the staging repo it will be overwritten.
These artifacts in the staging repo should be viewed as release candidates, and are the prime
artifacts for integration and user acceptance testing.

The python-release job builds the project and pushes the build artifacts to an index named
"PyPi.release" in the Linux Foundation's Nexus 3 repository.  This job must be triggered
manually by posting a comment "release" in the appropriate Gerrit review request.  Note that
if the same version of the artifact already exists in the release repo the push will fail.
Note also the deviation from Java release practices: this release job re-builds the artifact
where in the Java/Maven workflow a staged artifact is copied.

Library authors can configure pip to pull artifacts from either of these Nexus3 PyPI URLS:

    Nexus3 PyPI staging URL: https://nexus3.acumos.org/repository/PyPi.staging/
    Nexus3 PyPI release URL: https://nexus3.acumos.org/repository/PyPi.release/

## Testing the templates

These instructions explain how to test the Acumos templates using the Jenkins sandbox.
This will catch errors before submitting the changes as Gerrit reviews.  Prerequisites:

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

This explains how to run verify a job in the Sandbox on an open review.
Most "verify" jobs accept parameters to build code in a review submitted to
Gerrit.  You must specify the change ref spec, which is a Git branch name. 
Get this by inspecting Gerrit's "download" links at the top right.  The branch
name will be something like this:

	refs/changes/78/578/2

The first number is a mystery to me; the second number is the Gerrit change number;
the third number is the patch set within the change.

Enter this name for both the GERRIT_BRANCH and the GERRIT_REFSPEC parameters, then
click Build.
