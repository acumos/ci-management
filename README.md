# Continuous Integration for Acumos at LF

This repository has resources to generate jobs in the Linux Foundation Jenkins instance
using the Jenkins Job Builder https://docs.openstack.org/infra/system-config/jjb.html

## Testing the templates 

To test the Acumos templates locally (instead of submitting Gerrit reviews and waiting):

1. Check out the global JJB templates submodule within this repo:

    git submodule update --init

2. Run the Jenkins job-builder script in this directory:

    jenkins-jobs test -r jjb
