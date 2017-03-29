export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"
export LANGUAGE="en_US.UTF-8"
export EDITOR="nano"
export SSH_KEY_PATH="~/.ssh/id_rsa"
export PAGER="less"
export MANPAGER="less -X"
export LESSOPEN="| pygmentize %s"
less_options=(
  # If the entire text fits on one screen, just show it and quit. (Be more
  # like "cat" and less like "more".)
  --quit-if-one-screen

  # Do not clear the screen first.
  --no-init

  # Like "smartcase" in Vim: ignore case unless the search pattern is mixed.
  --ignore-case

  # Do not automatically wrap long lines.
  --chop-long-lines

  # Allow ANSI colour escapes, but no other escapes.
  --RAW-CONTROL-CHARS

  # Do not ring the bell when trying to scroll past the end of the buffer.
  --quiet

  # Do not complain when we are on a dumb terminal.
  --dumb
);
export LESS="${less_options[*]}"


function start_agent {
	echo "Initializing new SSH agent..."
	touch $SSH_ENV
	chmod 600 "${SSH_ENV}"
	/usr/bin/ssh-agent | sed 's/^echo/#echo/' >> "${SSH_ENV}"
	. "${SSH_ENV}" > /dev/null
	/usr/bin/ssh-add
}

# Use ssh-agent only for WSL
if grep -q "Microsoft" /proc/version; then
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

	# Workaround for WSL (Bash on Windows)
	export BROWSER="/mnt/c/Program Files (x86)/Google/Chrome/Application/chrome.exe"
fi

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
