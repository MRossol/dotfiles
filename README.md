# dotfiles
dotfiles needed to sync environment settings

# Install fonts on Mac:
https://support.apple.com/en-us/HT201749

# Install zsh
`sudo apt-get install zsh`
or `conda install zsh -c conda-forge`
`sudo chsh -s /usr/bin/zsh $USER`

# Install zsh dependancies
`./install.sh`

# Run bootstrap
`./bootstrap.sh`

# Jupyter install
`conda install jupyter`

## Jupyter Notebook Extensions
`conda install -c conda-forge jupyter_contrib_nbextensions`

## Conda Kernels
`conda install nb_conda_kernels` # Currently not available for python 3.9
In each env: `conda install ipykernel`
If using 3.9 in each env also run:
`ipython kernel install --user --name=<env-name>`

To uninstall kernel: `jupyter kernelspec uninstall <env-name>`
