# Path
export PATH="$HOME/.local/bin:$HOME/.claude:$HOME/.bun/bin:$HOME/bin:$PATH"

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git docker extract zsh-autosuggestions)
source $ZSH/oh-my-zsh.sh

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"

# fzf
source <(fzf --zsh)

# zoxide (smarter cd)
eval "$(zoxide init zsh)"
export FZF_CTRL_T_OPTS='--preview "bat --color=always {}" --preview-window=right:50%:wrap'
export FZF_ALT_C_OPTS='--preview "tree -C {} | head -100"'

# fzf+rg: search contents, open at line
fzg() {
    [[ $# -eq 0 ]] && { echo "Usage: fzg <pattern>"; return 1; }
    local sel=$(rg --line-number --no-heading --color=always "$1" | fzf --ansi --delimiter : --preview 'bat --color=always {1} --highlight-line {2}' --preview-window=right:60%:wrap)
    [[ -n $sel ]] && nvim "+$(echo $sel | cut -d: -f2)" "$(echo $sel | cut -d: -f1)"
}

# Aliases
alias vim='nvim'
alias v.='nvim .'
alias lg='lazygit'

# Local overrides (not tracked)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
[[ -f ~/.secrets ]] && source ~/.secrets
