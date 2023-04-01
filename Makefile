include common.makefile
# OPTIONS
PYTHON2_VIRTUAL_ENV :=
PYTHON2_VIRTUAL_ENV :=
PYPI2_PACKAGE:=numpy matplotlib ipython

PYTHON3_VERSION     :=3.9.4
PYTHON3_VIRTUAL_ENV :=example_python_env
PYPI3_PACKAGE:=jupyterlab ipympl sympy pandas control PyYAML openpyxl

USE_PROXY           :=false
PROXY_SERVER        := example.com
PORT                := 80

# DO NOT EDIT BELOW THIS LINE
MAKE_SOURCE_DIR:=$(abspath $(dir $(lastword $(MAKEFILE_LIST))))
include .python_project/common.makefile
