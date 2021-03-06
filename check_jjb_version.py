# SPDX-License-Identifier: EPL-1.0
##############################################################################
# Copyright (c) 2020 The Linux Foundation and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
##############################################################################
"""Ensures that the jjb-version in tox and ci-management.yaml match."""

__author__ = "Anil Belur"


import os
import re
import sys
import logging

log = logging.getLogger(__name__)

def check_jjb_version(tox_file, releng_jobs_file):
    """Check that JJB version matches in job cfg and tox.ini."""
    with open(tox_file, "r") as _file:
        for num, line in enumerate(_file, 1):
            if re.search("env:JJB_VERSION:", line):
                jjb_version_tox = line.rsplit(":", 1)[1].replace("}", "").strip()
                break

    with open(releng_jobs_file, "r") as _file:
        for num, line in enumerate(_file, 1):
            if re.search("jjb-version: ", line):
                jjb_version = line.rsplit(":", 1)[1].strip()
                break

    log.info("JJB version in jjb/ci-management/ci-management.yaml: {}".format(jjb_version))
    log.info("JJB version in tox.ini: {}".format(jjb_version_tox))

    if jjb_version != jjb_version_tox:
        log.info("ERROR: JJB version in jjb/ci-management/ci-management.yaml and tox.ini MUST match.")
        sys.exit(1)


if __name__ == "__main__":
    check_jjb_version("tox.ini", os.path.join("jjb/ci-management", "ci-management.yaml"))
