# USER OPTIONS
PYTHON3_VERSION:=3.9.4
PYTHON3_VIRTUAL_ENV:=example_python_env
USE_PROXY:=false

# Variable definitions
SHELL:=/bin/bash
MAKE_SOURCE_DIR:=$(abspath $(dir $(lastword $(MAKEFILE_LIST))))
SUDO:=sudo -E
YES:=-y --allow-unauthenticated
APT:=apt-get
PYPI2_PACKAGE:=numpy matplotlib ipython
PYPI3_PACKAGE:=jupyterlab ipympl sympy pandas control PyYAML openpyxl

# Public targets
help: ## Show this help
	@for f in $(MAKEFILE_LIST); do \
		grep -E '^[a-zA-Z_-]+:.*?## .*$$' $$f | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}';\
	done

SETUP-DEPS := $(PYENV_ROOT)/versions/$(PYTHON3_VIRTUAL_ENV)/
SETUP-DEPS += python2-packages
SETUP-DEPS += python3-packages
SETUP-DEPS += /usr/share/fonts/truetype/takao-gothic/TakaoGothic.ttf
SETUP-DEPS += notebooks
setup: $(SETUP-DEPS) ## Setup project

start-jupyterlab: notebooks ## Start jupyter-lab
	export MAKE_SOURCE_DIR=$(shell cd $(MAKE_SOURCE_DIR); pwd); \
	cd $(MAKE_SOURCE_DIR)/notebooks && jupyter lab --no-browser

start-notebook: notebooks ## Start jupyter notebook
	export MAKE_SOURCE_DIR=$(shell cd $(MAKE_SOURCE_DIR); pwd); \
	cd $(MAKE_SOURCE_DIR)/notebooks && jupyter notebook --no-browser

start-ipython: ## Start ipython
	export MAKE_SOURCE_DIR=$(shell cd $(MAKE_SOURCE_DIR); pwd); \
	cd $(MAKE_SOURCE_DIR) && ipython

debug: PROXY-SETTING
	@# Common parameters
	@echo MAKE_SOURCE_DIR: $(MAKE_SOURCE_DIR)
	@# Proxy variables
	@echo USE_PROXY: $(USE_PROXY)
	@echo PROXY_URL: $(PROXY_URL)
	@# pyenv
	@echo PYENV_ROOT: ${PYENV_ROOT}
	@# Python environments
	@echo PYTHON3_VIRTUAL_ENV: $(PYTHON3_VIRTUAL_ENV)

	@echo PYPI2_PACKAGE:
	@for p in $(PYPI2_PACKAGE); do \
		echo " - $$p";\
	done

	@echo PYPI3_PACKAGE:
	@for p in $(PYPI3_PACKAGE); do \
		echo " - $$p";\
	done

# for developper
${PYENV_ROOT}/versions/$(PYTHON3_VIRTUAL_ENV)/:
	-@echo "checking $@";\
	if [ -d $@ ]; then \
		echo "OK"; \
	else \
		# export http_proxy=http://$(USER_ID):$(USER_PASS)@$(PROXY_SERVER):$(PORT); \
		# export https_proxy=http://$(USER_ID):$(USER_PASS)@$(PROXY_SERVER):$(PORT); \
		CONFIGURE_OPTS="--enable-shared" pyenv install $(PYTHON3_VERSION) -v;\
		pyenv virtualenv $(PYTHON3_VERSION) $(PYTHON3_VIRTUAL_ENV);\
		echo "Python $(PYTHON3_VIRTUAL_ENV) was successfully installed!";\
	fi

# Install python packages
python2-packages: PROXY-SETTING
	@echo "Installing Python2 packages...";\
	if [ -n $(PROXY_URL) ]; then \
		export http_proxy=http://$(USER_ID):$(USER_PASS)@$(PROXY_SERVER):$(PORT); \
		export https_proxy=http://$(USER_ID):$(USER_PASS)@$(PROXY_SERVER):$(PORT); \
	fi; \
	export PACKAGES=($(PYPI2_PACKAGE));\
	for p in $$PACKAGES; do \
		pyenv exec pip install $$p;\
	done

python3-packages: ${PYENV_ROOT}/versions/$(PYTHON3_VIRTUAL_ENV)/ PROXY-SETTING
	@echo "$(MAKE_SOURCE_DIR)/notebooks"
	echo "Install Python3 packages...";\
	if [ -n $(PROXY_URL) ]; then \
		export http_proxy=http://$(USER_ID):$(USER_PASS)@$(PROXY_SERVER):$(PORT); \
		export https_proxy=http://$(USER_ID):$(USER_PASS)@$(PROXY_SERVER):$(PORT); \
	fi; \
	source ${PYENV_ROOT}/versions/$(PYTHON3_VIRTUAL_ENV)/bin/activate; \
	export PACKAGES=($(PYPI3_PACKAGE)); \
	for p in $$PACKAGES; do \
		echo $$p;\
		pyenv exec pip install $$p;\
	done

/usr/share/fonts/truetype/takao-gothic/TakaoGothic.ttf:
	$(SUDO) $(APT) install fonts-takao-gothic $(YES)

notebooks:
	cd $(MAKE_SOURCE_DIR); \
	mkdir notebooks; \
	cd notebooks; \
	pyenv local $(PYTHON3_VIRTUAL_ENV)

.PHONY: help python2-packages python3-packages PROXY-SETTING

PROXY_SERVER = example.com
PORT         = 80
PROXY-SETTING:
ifeq ($(USE_PROXY), true)
	$(eval USER_ID := $(shell read -p "LOGIN ID: " USER_ID; echo "$${USER_ID}"))
	$(eval USER_PASS := $(shell read -s -p "LOGIN PASS: " USER_PASS; echo "$${USER_PASS}"))
	$(eval PROXY_URL := http://$(USER_ID):$(USER_PASS)@$(PROXY_SERVER):$(PORT))
else
	$(eval PROXY_URL := "")
endif
