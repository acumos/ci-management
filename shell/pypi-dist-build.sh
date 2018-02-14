#!/bin/bash

# Script to build PyPI artifacts

# Create and activate virtualenv
virtualenv /tmp/v/twine
source "/tmp/v/twine/bin/activate"

# Install twine
pip install twine

# Install wheel
pip install wheel

# Create distribution
python setup.py sdist bdist_wheel
