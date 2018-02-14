# Continuous Integration for Acumos at LF

This repository has templates that generate jobs in the Linux Foundation Jenkins instance
using the Jenkins Job Builder.  For more information about that tool please see:

    https://docs.openstack.org/infra/system-config/jjb.html

## Template design

Acumos jobs are generated from standard Global JJB templates and from custom-to-project
templates.

### Global JJB templates

Global JJB templates are used as much as possible. As of this writing this includes
CLM, RST/RTD documentation, javadoc, python and simple Maven/Java jar jobs.

Note that the Global JJB jobs originated with the Open Daylight project and reflect
CI/CD design choices made there.

Documentation of Global JJB templates can be found here:

    http://global-jjb.releng.linuxfoundation.org/en/latest/index.html

#### Docker issues

As of this writing Global JJB provides no support for use of a Docker Maven plugin.
The Global JJB docker jobs assume all resources will be pulled from network resources such
as the Nexus jar repository first, but it makes little sense to deploy Spring-repackaged
super jars of 50+ MB each that are not intended for public consumption.

#### Maven goal issues

Most Global JJB jobs use the "deploy" goal, currently hardcoded in shell scripts.
This is inappropriate for Acumos docker projects because that goal causes a docker
image to be pushed to a Docker registry.  For example, every javadoc and sonar job
does a full build, but should not push docker images.

### Custom JJB templates

Custom JJB templates are used for Maven/Java verify, build and release jobs on
projects that use docker.  Acumos has multiple projects that build a jar then
wrap it into a docker image using a Maven plugin.  These templates are derived
from the Global JJB templates of similar names.  The only notable change is
adding invocation of a "builder" (aka shell script) that obtains Nexus3 docker
registry credentials and logs in at the nexus3.acumos.org registry.  With that
prerequisite met, the Maven docker plugin succeeds in pulling and pushing images.

#### Python Custom JJB Templates
If a Python project needs to publish artifacts to the Nexus3 PyPI repositories,
we have python-release and python-staging jobs.

A Python project can add these jobs to their project.yaml file

    jobs:
      - '{project-name}-python-release-{stream}'
      - '{project-name}-python-staging-{stream}'

The python-release is triggered by a comment of `release`, builds the app, and
pushes it to PyPi.release in Nexus 3.  Note that if the same version of the app
already exists in the release repos the push will be rejected. python-staging is
triggered by a comment of `remerge` and also a gerrit merge event.  It too
builds the app but instead, pushes it PyPi.staging in Nexus3.  This will
overwrite a similiarly versioned app in the staging repo.  These artifacts in
the staging repo should be viewed as "release candidates".  These are the
artifacts you will concentrate your integration/user acceptance testing on.

Nexus3 PyPI URLS

    Nexus3 PyPI staging URL: https://nexus3.acumos.org/repository/PyPi.staging/
    Nexus3 PyPI release URL: https://nexus3.acumos.org/repository/PyPi.release/

## Testing the templates

These instructions explain how to test the Acumos templates before submitting Gerrit reviews.
Prerequisites:

Install the Jenkins job builder:

    pip install --user jenkins-job-builder

Check out the global JJB templates submodule within this repo:

    git submodule update --init

### Test Locally

Check sanity by running the Jenkins job-builder script in this directory:

    jenkins-jobs test -r jjb

### Deploy the templates to the Jenkins sandbox

Login (after requesting permission) at the Jenkins sandbox:

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

Most "verify" jobs accept parameters to build code in a review submitted to
Gerrit.  You will need the change ref spec, which is a Git branch name.  Get
this by inspecting Gerrit's "download" links at the top right.  The branch
name will be something like this:

	refs/changes/78/578/2

The first number is a mystery to me; the second number is the Gerrit change number;
the third number is the patch set within the change.

Enter this name for both the GERRIT_BRANCH and the GERRIT_REFSPEC parameters, then
click Build.
