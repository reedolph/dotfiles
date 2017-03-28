function start_agent {
    echo "Initializing new SSH agent..."
    touch $SSH_ENV
    chmod 600 "${SSH_ENV}"
    /usr/bin/ssh-agent | sed 's/^echo/#echo/' >> "${SSH_ENV}"
    . "${SSH_ENV}" > /dev/null
    /usr/bin/ssh-add
}

# Use ssh-agent only for Windows and remote boxes
if [ -z "${DESKTOP_SESSION}" ]; then
	# Set up ssh-agent
	SSH_ENV="$HOME/.ssh/environment"

	# Source SSH settings, if applicable
	if [ -f "${SSH_ENV}" ]; then
	    . "${SSH_ENV}" > /dev/null
	    kill -0 $SSH_AGENT_PID 2>/dev/null || {
	        start_agent
	    }
	else
	    start_agent
	fi
fi

# Workarounds for WSL (Bash on Windows)
POWERLEVEL9K_INSTALLATION_PATH="${HOME}/.antigen/repos/https-COLON--SLASH--SLASH-github.com-SLASH-bhilburn-SLASH-powerlevel9k.git/powerlevel9k.zsh-theme"
ZSH_CACHE_DIR="/home/jaakko/.antigen/repos/https-COLON--SLASH--SLASH-github.com-SLASH-robbyrussell-SLASH-oh-my-zsh.git/cache/"
autoload -Uz is-at-least
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

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
