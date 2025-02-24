
# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
alias ls='ls --color=auto'
#alias dir='dir --color=auto'
#alias vdir='vdir --color=auto'

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi




alias vpn='openvpn2 --config ${HOME}/apps/vpn-config/vpn.ovpn --auth-user-pass ${HOME}/.cert/client-edited-mfa.credentials'
alias lc='tac ~/apps/skuscraper/output.txt | grep -B 27 -A 12 -m 1 elapsed_time_seconds | tac'



#export PATH=/opt/viber/:/usr/bin:/usr/bin:/usr/bin:/usr/bin:/home/stanislav/.pyenv/shims:/home/stanislav/.pyenv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/snap/bin:/opt/nvim-linux64/bin:/usr/local/go/bin:~/.local/bin:~/go/bin:

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


# SOURCING
# git
. ~/personal/git/contrib/completion/git-prompt.sh


# Colors and styles
BOLD="\[\033[1m\]"
RESET="\[\033[0m\]"
CWD_COLOR="\[\033[0;34m\]"  # Choose your preferred color, 34 is blue

# Git prompt settings
GIT_PS1_SHOWCOLORHINTS=1

# Set the prompt
export PS1="${BOLD}${CWD_COLOR}\w${RESET}\$(__git_ps1 ' (%s)')${RESET}\$ "

# linux
#. /usr/share/autojump/autojump.sh
# mac
[ -f /opt/homebrew/etc/profile.d/autojump.sh ] && . /opt/homebrew/etc/profile.d/autojump.sh

# ALIASES
alias vim=nvim
alias vim.config="vim ~/.config/nvim"
alias vim.bash="vim ~/.bashrc"
alias vim.i3="vim ~/.config/i3/config"
alias vim.tmux="vim ~/.tmux.conf"
alias vim.ala="vim ~/.config/alacritty/alacritty.toml"

alias tls="cd ~/apps/tls-unblocker-pop/; uvicorn app.main:app --reload --port 19904 --host 0.0.0.0 --no-access-log"
alias sp="cd ~/apps/smart-proxy/; node bin/server.js"

alias vim.skuscraper="cd ~/apps/skuscraper/; vim ."
alias vim.tls="cd ~/apps/tls-unblocker-pop/; vim ."
alias vim.hydra="cd ~/apps/hydra/; vim ."
alias vim.smart="cd ~/apps/smart-proxy/; vim ."

alias viber="nohup Viber &"

# ktd qol
alias ks="ktd status"
alias kl="ktd status | grep '^ ' | awk '{print \$3}' | fzf | xargs ktd logs -n 100"
alias ke="ktd status | grep '^ ' | awk '{print \$3}' | fzf | xargs -I {} tmux split-window -h 'ktd enter {}'"
alias ku="ktd status | grep '^ ' | awk '{print \$3}' | fzf | xargs ktd up"

# git
alias gs="git status"
alias gf="git commit --fixup"
alias gc="git commit -m"
alias gol="git log --oneline"
alias gg="git log --oneline --graph"

# ENVs
export SPACE=WORK
export DEV_SMART_PROXY_PORT=8080
export SMARTPROXY_TLS_UNBLOCKER_POP_HOST=localhost
export SMARTPROXY_TLS_UNBLOCKER_POP_PORT=19904
export SMARTPROXY_BROWSER_FARM_HOST=localhost
export SMARTPROXY_BROWSER_FARM_PORT=23505

export EDITOR=nvim
export VISUAL=nvim

eval "$(/opt/homebrew/bin/brew shellenv)"
