# Pre-commit
This repository uses [pre-commit](https://pre-commit.com/) hooks to manage code style and quality standards.

## Installation
First install the pre-commit package

    pip install pre-commit

The following files need to be present in the repo to install the actual pre-commit hooks:

1. .pre-commit-config.yaml
2. .pylintrc
3. .flake8

Next install the pre-commit hooks defined in .pre-commit-config.yaml

    cd ../rev2
    pre-commit install

## Test hooks
To test your files before committing, stage them

    git add file or git add .
    pre-commit run --all-files
