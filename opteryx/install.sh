#!/bin/bash
# Opteryx is an embedded Python library (opteryx-core on PyPI): no server to start.
# Python 3.14 from deadsnakes (Ubuntu 24.04 ships 3.12); opteryx-core ships cp314 x86_64 wheels.
OPTERYX_VERSION="${OPTERYX_VERSION:-0.9.153}"
sudo apt-get update -y -q
sudo apt-get install -y -q software-properties-common pigz
sudo add-apt-repository -y ppa:deadsnakes/ppa
sudo apt-get update -y -q
sudo apt-get install -y -q python3.14 python3.14-venv
python3.14 -m venv ~/opteryx_venv
~/opteryx_venv/bin/pip install -q --upgrade pip
~/opteryx_venv/bin/pip install -q "opteryx-core==${OPTERYX_VERSION}"
~/opteryx_venv/bin/python -c "import opteryx; print('opteryx', opteryx.__version__)"
