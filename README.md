# Continuous Integration for Acumos at LF

This repository has resources to generate jobs in the Linux Foundation Jenkins instance
using the Jenkins Job Builder https://docs.openstack.org/infra/system-config/jjb.html

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

Login (or request permission to login) at the Jenkins sandbox:

    https://jenkins.acumos.org/sandbox

Get the authentication token from the sandbox:
    a) click on your user name (top right)
    b) click Configure (left menu)
    c) click API Token (button)

Create a config file jenkins.ini using this template and your credentials:

	[job_builder]
	ignore_cache=True
	keep_descriptions=False
	recursive=True

	[jenkins]
	query_plugins_info=False
	url=https://jenkins.acumos.org/sandbox
	user=YOUR-USER-NAME
	password=YOUR-API-TOKEN

Build and deploy a specific job:

    jenkins-jobs --conf jenkins.ini update jjb your-job-name-here

In the sandbox find the job then click the button "Build with parameters"
