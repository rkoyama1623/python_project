# # USER OPTIONS
# PYTHON2_VERSION=system
# PYTHON2_VIRTUAL_ENV:=
# PYPI2_PACKAGE:=

# PYTHON3_VERSION:=
# PYTHON3_VIRTUAL_ENV:=
# PYPI3_PACKAGE:=

# USE_PROXY=false
# PROXY_SERVER :=
# PORT         :=

# MAKE_SOURCE_DIR:=

# Variable definitions
SHELL:=/bin/bash
SUDO:=sudo -E
YES:=-y --allow-unauthenticated
APT:=apt-get

# Public targets
help: ## Show this help
	@for f in $(MAKEFILE_LIST); do \
		grep -E '^[a-zA-Z_-]+:.*?## .*$$' $$f | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}';\
	done

SETUP-DEPS=
# Python2
ifeq ($(PYTHON2_VIRTUAL_ENV),)
else
	SETUP-DEPS += $(PYENV_ROOT)/versions/$(PYTHON2_VIRTUAL_ENV)/
endif
ifeq ($(PYPI2_PACKAGE),)
else
	SETUP-DEPS += python2-packages
endif
# Python3
ifeq ($(PYTHON3_VIRTUAL_ENV),)
else
	SETUP-DEPS += $(PYENV_ROOT)/versions/$(PYTHON3_VIRTUAL_ENV)/
endif
ifeq ($(PYPI3_PACKAGE),)
else
	SETUP-DEPS += python3-packages
endif
SETUP-DEPS += /usr/share/fonts/truetype/takao-gothic/TakaoGothic.ttf # For Japanese characters in matplotlib
SETUP-DEPS += notebooks

${PYENV_ROOT}/versions/$(PYTHON2_VIRTUAL_ENV)/:
	-@echo "checking $@";\
	if [ -d $@ ]; then \
		echo "OK"; \
	else \
		# export http_proxy=http://$(USER_ID):$(USER_PASS)@$(PROXY_SERVER):$(PORT); \
		# export https_proxy=http://$(USER_ID):$(USER_PASS)@$(PROXY_SERVER):$(PORT); \
		if [ -n $(PYTHON2_VERSION) ]; then \
			CONFIGURE_OPTS="--enable-shared" pyenv install $(PYTHON2_VERSION) -v;\
		fi; \
		if [ -n $(PYTHON2_VIRTUAL_ENV) ]; then \
			pyenv virtualenv $(PYTHON2_VERSION) $(PYTHON2_VIRTUAL_ENV);\
			echo "Python $(PYTHON2_VIRTUAL_ENV) was successfully installed!";\
		fi; \
	fi

${PYENV_ROOT}/versions/$(PYTHON3_VIRTUAL_ENV)/:
	-@echo "checking $@";\
	if [ -d $@ ]; then \
		echo "OK"; \
	else \
		# export http_proxy=http://$(USER_ID):$(USER_PASS)@$(PROXY_SERVER):$(PORT); \
		# export https_proxy=http://$(USER_ID):$(USER_PASS)@$(PROXY_SERVER):$(PORT); \
		if [ -n $(PYTHON3_VERSION) ]; then \
			CONFIGURE_OPTS="--enable-shared" pyenv install $(PYTHON3_VERSION) -v;\
		fi; \
		if [ -n $(PYTHON3_VIRTUAL_ENV) ]; then \
			pyenv virtualenv $(PYTHON3_VERSION) $(PYTHON3_VIRTUAL_ENV);\
			echo "Python $(PYTHON3_VIRTUAL_ENV) was successfully installed!";\
		fi; \
	fi

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
	@echo "---------------------------"
	@echo \# Common parameters
	@echo MAKE_SOURCE_DIR: $(MAKE_SOURCE_DIR)
	@echo
	@echo \# Proxy variables
	@echo USE_PROXY: $(USE_PROXY)
	@echo USER_ID: $(USER_ID)
	@echo USER_PASS: $(USER_PASS)
	@echo PROXY_URL: $(PROXY_URL)
	@echo
	@echo \# pyenv
	@echo PYENV_ROOT: ${PYENV_ROOT}
	@echo
	@echo \# Python environments
	@echo PYTHON2_VERSION: $(PYTHON2_VERSION)
	@echo PYTHON2_VIRTUAL_ENV: $(PYTHON2_VIRTUAL_ENV)
	@echo PYTHON3_VERSION: $(PYTHON3_VERSION)
	@echo PYTHON3_VIRTUAL_ENV: $(PYTHON3_VIRTUAL_ENV)
	@echo
	@echo \# PYPI2_PACKAGE:
	@for p in $(PYPI2_PACKAGE); do \
		echo " - $$p";\
	done
	@echo
	@echo \# PYPI3_PACKAGE:
	@for p in $(PYPI3_PACKAGE); do \
		echo " - $$p";\
	done
	@echo 
	@echo \# SETUP-DEPS:
	@for p in $(SETUP-DEPS); do \
		echo " - $$p";\
	done

# for developper

# Install python packages
python2-packages: ${PYENV_ROOT}/versions/$(PYTHON2_VIRTUAL_ENV)/ PROXY-SETTING
	@echo "Installing Python2 packages...";\
	if $(USE_PROXY); then \
		echo "Using proxy: $(PROXY_URL)"; \
		export http_proxy=http://$(USER_ID):$(USER_PASS)@$(PROXY_SERVER):$(PORT); \
		export https_proxy=http://$(USER_ID):$(USER_PASS)@$(PROXY_SERVER):$(PORT); \
	fi; \
	if [ $(PYTHON2_VERSION) != "system" ]; then \
		if [ -n $(PYTHON2_VIRTUAL_ENV) ]; then \
			source ${PYENV_ROOT}/versions/$(PYTHON2_VIRTUAL_ENV)/bin/activate; \
		fi; \
	fi; \
	for p in $(PYPI2_PACKAGE); do \
		echo " - $$p";\
	done; \
	for p in $(PYPI2_PACKAGE); do \
		echo $$p;\
		pyenv exec pip install $$p;\
	done

python3-packages: ${PYENV_ROOT}/versions/$(PYTHON3_VIRTUAL_ENV)/ PROXY-SETTING
	@echo "$(MAKE_SOURCE_DIR)/notebooks"
	echo "Install Python3 packages...";\
	if $(USE_PROXY); then \
		export http_proxy=http://$(USER_ID):$(USER_PASS)@$(PROXY_SERVER):$(PORT); \
		export https_proxy=http://$(USER_ID):$(USER_PASS)@$(PROXY_SERVER):$(PORT); \
	fi; \
	if [ $(PYTHON3_VERSION) != "system" ]; then \
		if [ -n $(PYTHON3_VIRTUAL_ENV) ]; then \
			source ${PYENV_ROOT}/versions/$(PYTHON3_VIRTUAL_ENV)/bin/activate; \
		fi; \
	fi; \
	for p in $(PYPI3_PACKAGE); do \
		echo " - $$p";\
	done; \
	for p in $(PYPI3_PACKAGE); do \
		echo $$p;\
		pyenv exec pip install $$p;\
	done

/usr/share/fonts/truetype/takao-gothic/TakaoGothic.ttf:
	$(SUDO) $(APT) install fonts-takao-gothic $(YES)

notebooks:
	cd $(MAKE_SOURCE_DIR); \
	mkdir -p notebooks; \
	cd notebooks; \
	if [ -n $(PYTHON3_VIRTUAL_ENV) ]; then \
		pyenv local $(PYTHON3_VIRTUAL_ENV); \
	fi;

.PHONY: help python2-packages python3-packages PROXY-SETTING

PROXY-SETTING:
	$(eval USER_ID = $(shell if $(USE_PROXY); then read -p "LOGIN ID: " USER_ID; fi; echo "$${USER_ID}"))
	$(eval USER_PASS := $(shell if $(USE_PROXY); then read -s -p "LOGIN PASS: " USER_PASS; fi; echo "$${USER_PASS}"))
	$(eval PROXY_URL := $(shell if $(USE_PROXY); then echo http://$(USER_ID):$(USER_PASS)@$(PROXY_SERVER):$(PORT); else echo ""; fi))
	@echo ""
