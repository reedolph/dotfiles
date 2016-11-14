# Antigen
. "${HOME}/.antigenrc"

# Use syntax highlighting in cat
function cat () { [ -t 1 ] && command cat $@ | pygmentize -g || command cat $@ }

# Use colors in ls by default
alias ls='ls --color=auto'

# Use LS_COLORS for colored completion
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

# Node Version Manager
export NVM_DIR="${HOME}/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
