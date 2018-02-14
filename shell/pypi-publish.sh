#!/bin/bash

# Script to publush PyPI artifacts

# Create and activate virtualenv
virtualenv /tmp/v/twine
source "/tmp/v/twine/bin/activate"

# Install twine
pip install twine

# Upload artifacts
twine upload -r $PYPI_SERVER dist/*
