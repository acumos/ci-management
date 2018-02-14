#!/bin/bash

# Script to publush PyPI artifacts

virtualenv /tmp/v/twine
source "/tmp/v/twine/bin/activate"

pip install twine

twine upload -r $PYPI_SERVER dist/*
