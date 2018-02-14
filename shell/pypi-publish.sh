#!/bin/bash

# Script to push PyPI artifacts to the Nexus3 staging repository

# Activate previously created virtualenv for tox
source "/tmp/v/tox/bin/activate"

# Install twine
pip install twine

# Create distribution
python setup.py sdist bdist_wheel

# Upload artifact to Nexus3 staging repository
twine upload -r $PYPI_SERVER dist/*
