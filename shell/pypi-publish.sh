#!/bin/bash

# Script to push PyPI artifacts 

# Create and activate virtualenv
virtualenv /tmp/v/twine
source "/tmp/v/twine/bin/activate"

# Install twine
pip install twine

# Create distribution
python setup.py sdist bdist_wheel

# Upload artifacts
twine upload -r $PYPI_SERVER dist/*
