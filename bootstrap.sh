#!/usr/bin/env bash
echo "Symlinking files from $(pwd)"
mkdir -p ~/.config
mkdir -p ~/.config/bat
mkdir -p ~/.git-templates
mkdir -p ~/.git-templates/hooks

if [ -f $HOME/Library/Fonts ]; then
        cp $(pwd)/fonts/* $HOME/Library/Fonts/
else
        mkdir -p $HOME/.fonts
        cp $(pwd)/fonts/* $HOME/.fonts
fi

if [ -f $HOME/.bash_profile ]; then
        cp $HOME/.bash_profile $HOME/.bash_profile.bak
fi
rm ~/.bash_profile
ln -s $(pwd)/.bash_profile ~/.bash_profile

if [ -f $HOME/.bashrc ]; then
        cp $HOME/.bashrc $HOME/.bashrc.bak
fi
rm ~/.bashrc
ln -s $(pwd)/.bashrc ~/.bashrc

rm ~/.zshenv
ln -s $(pwd)/.zshenv ~/.zshenv
rm ~/.zshrc
ln -s $(pwd)/.zshrc ~/.zshrc
rm ~/.p10k.zsh
ln -s $(pwd)/.p10k.zsh ~/.p10k.zsh

rm ~/.fzf.bash
ln -s $(pwd)/.fzf.bash ~/.fzf.bash
rm ~/.fzf.zsh
ln -s $(pwd)/.fzf.zsh ~/.fzf.zsh

rm ~/.condarc
ln -s $(pwd)/.condarc ~/.condarc

rm ~/.config/flake8
ln -s $(pwd)/.flake8 ~/.config/flake8
rm ~/.config/pycodestyle
ln -s $(pwd)/.pycodestyle ~/.config/pycodestyle
rm ~/.config/.exports
ln -s $(pwd)/.exports ~/.config/.exports
rm ~/.config/.aliases
ln -s $(pwd)/.aliases ~/.config/.aliases
rm ~/.config/.fzf.bash
ln -s $(pwd)/.fzf.bash ~/.config/.fzf.bash
rm ~/.config/.fzf.zsh
ln -s $(pwd)/.fzf.zsh ~/.config/.fzf.zsh

rm -rf ~/.config/bat/config
ln -s $(pwd)/.batconfig ~/.config/bat/config

rm ~/.gitconfig
ln -s $(pwd)/.gitconfig ~/.gitconfig
rm ~/.gitignore
ln -s $(pwd)/.gitignore ~/.gitignore
rm ~/.pre-commit-config.yaml
ln -s $(pwd)/.pre-commit-config.yaml ~/.pre-commit-config.yaml
rm ~/.git-template/hooks/pre-commit
ln -s $(pwd)/.git-templates/hooks/pre-commit ~/.git-templates/hooks/pre-commit
chmod -R a+X $(pwd)/.git-templates
chmod -R a+X ~/.git-templates

rm ~/.pylintrc
ln -s $(pwd)/.pylintrc ~/.pylintrc

rm ~/.gitconfig-enterprise
ln -s $(pwd)/.gitconfig-enterprise ~/.gitconfig-enterprise
