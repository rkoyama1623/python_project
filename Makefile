# OPTIONS
PYTHON2_VERSION     := 2.7.17
PYTHON2_VIRTUAL_ENV := example_env_py2
PYPI2_PACKAGE       := numpy matplotlib ipython

PYTHON3_VERSION     := 3.9.4
PYTHON3_VIRTUAL_ENV := example_env_py3
PYPI3_PACKAGE       := numpy matplotlib ipython

USE_PROXY           :=false
PROXY_SERVER        := example.com
PORT                := 80

# DO NOT EDIT BELOW THIS LINE
MAKE_SOURCE_DIR:=$(abspath $(dir $(lastword $(MAKEFILE_LIST))))
include .python_project/common.makefile
