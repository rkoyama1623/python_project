# python_project
## Demo
```bash
mkdir your_ausome_python_project && cd your_ausome_python_project
git init
git commit -m "initial commit" --allow-empty
git submodule add https://github.com/rkoyama1623/python_project .python_project
git commit -m "Add .python_project"
cp .python_project/Makefile .
git commit -m "Copy Makefile from .python_project"
make       # Show commands
make setup # Setup example environments
make start-jupyter
```

## Features
This git repository provide `Makefile` to setup your own python packages.

## Requirement
- OS: Ubuntu
- Tools:
    - Makefile
    - git

## Installation
```bash
sudo apt install makefile git
```

## Usage
### Basic usage
See the demo above.

## License
MIT.