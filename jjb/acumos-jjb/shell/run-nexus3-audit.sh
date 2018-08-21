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
echo "---> run-nexus3-audit.sh"

# Ensure we fail the job if any steps fail.
# DO NOT set -u as virtualenv's activate script has unbound variables
set -e -o pipefail

pattern="${PATTERN:-.\*}"
repo="${REPO:-}"

virtualenv --quiet "/tmp/v/n3a"
source "/tmp/v/n3a/bin/activate"
pip install --quiet --upgrade "pip==9.0.3" setuptools

git clone https://github.com/MightyNerdEric/nexus3-audit.git /tmp/n3a
pushd /tmp/n3a
pip install --quiet --upgrade -r requirements.txt
pip install --quiet --upgrade -e .

echo nexus3-audit.py -y --url "https://nexus3.acumos.org" --list "$pattern" "$repo"
nexus3-audit.py -y --url "https://nexus3.acumos.org" --list "$pattern" "$repo" > audit_list

echo "######## ALL IMAGES IN $repo MATCHING $pattern ARE LISTED BELOW ########"
cat audit_list
echo "############### END OF IMAGES IN $repo MATCHING $pattern ###############"

popd
cp -f /tmp/n3a/audit_list* .
