source $HOME/.config/.aliases
source $HOME/.config/.exports

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

source <(kubectl completion zsh)
autoload bashcompinit && bashcompinit && source /opt/homebrew/etc/bash_completion.d/ckutil

if type -P aws aws_completer >/dev/null; then
    complete -C aws_completer aws
fi
