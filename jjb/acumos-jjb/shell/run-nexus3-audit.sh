#!/bin/bash
# SPDX-License-Identifier: EPL-1.0
##############################################################################
# Copyright (c) 2017 The Linux Foundation and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
##############################################################################
echo "---> run-nexus-check.sh"

# Ensure we fail the job if any steps fail.
# DO NOT set -u as virtualenv's activate script has unbound variables
set -e -o pipefail

virtualenv --quiet "/tmp/v/nexus-check"
source "/tmp/v/nexus-check/bin/activate"
pip install --quiet --upgrade "pip==9.0.3" setuptools

git clone https://github.com/MightyNerdEric/nexus3-audit.git /tmp/n3a
pushd /tmp/n3a
pip install --quiet --upgrade -r requirements.txt
pip install --quiet --upgrade -e .

export NEXUSPASS=$NEXUS_PASS
echo nexus3-audit.py -u $NEXUS_USER -y --url "https://nexus3.acumos.org" --$ACTION "$PATTERN" $REPO
nexus3-audit.py -u $NEXUS_USER -y --url "https://nexus3.acumos.org" --$ACTION "$PATTERN" $REPO
