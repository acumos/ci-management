#!/bin/bash
# Ensure we fail the job if any steps fail
set -e -x
rsync -av --relative "$DOC_DIR" acumos-privdocs-rsync-elb-1197834036.us-west-2.elb.amazonaws.com::www/
