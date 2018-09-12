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
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

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

# if [ -t 1 ]; then
#   exec zsh
# fi

# neovim-remote
if [ -n "${NVIM_LISTEN_ADDRESS}" ]; then
  alias nvh='nvr -o'
  alias nvv='nvr -O'
  alias nv='nvr --remote'
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=106'
else
  alias nv="nvim"
fi

# Must-have shortcuts
alias updf="/mnt/c/Users/cbw/vimfiles/update.files.sh"
# to expand an alias in zsh: C-x a
# to expand an alias in bash: C-M-e or <Esc> C-e
# to edit current line in $EDITOR (usu. vim): C-x C-e
alias cdz="vim ~/.bashrc +'nnoremap q :qa!<CR>'"
alias sdz="source ~/.bashrc"
alias ..="cd .. && pwd && ls"
alias ...="cd ../.. && pwd && ls"
alias ....="cd ../../.. && pwd && ls"
cdd () {
  cd "$1" && pwd && ls;
}
mkcd () {
  mkdir -p -- "$1" &&
    cd -P -- "$1"
}
alias checksize="du -h -d 1 | sort -n" #display file sizes
mann () {
  if [ -z "$1" ]
  then
    echo "What manual page do you want?"
  else
    man $1 |
      # sed "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K|H]//g" |
      sed "s/.\//g" |
      vim -M - +'set nonu' +'set ls=1' +'nnoremap q :qa!<CR>'
  fi
}
alias lsa="ls -a -F"
alias lsal="ls -a -l -F"
alias cp="cp -v"
alias mv="mv -v"
unspace () {
  for f in "$@"; do
    mv "$f" "${f// /_}"
  done
}
respace () {
  for f in "$@"; do
    mv "$f" "${f//_/ }"
  done
}

# Path Aliases
alias cduser="cd ${USERPROFILE//\\/\\\\} && pwd && ls"

# youtube-dl aliases
youtube-dl3 () {
if [[ "$#" -eq 0 ]]; then
  echo "provide Youtube URL(s) to extract their mp3. Playlist URLs will have all their videos inside extracted."
else
  for filename in "$@"; do
    if [[ "${filename}" =~ .*www.youtube.com/watch?.* ]]; then
      youtube-dl -x --audio-format mp3 "$filename"
    else
      echo "$filename is not a youtube link"
    fi
  done
fi
}
youtube-dl4 () {
if [[ "$#" -eq 0 ]]; then
  echo "provide Youtube URL(s) to extract their mp4. Playlist URLs will have all their videos inside extracted."
else
  for filename in "$@"; do
    if [[ "${filename}" =~ .*www.youtube.com/watch?.* ]]; then
      youtube-dl -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/bestvideo+bestaudio' --merge-output-format mp4 "$filename"
    else
      echo "================================================================================"
      echo "$filename is not a youtube link"
      echo "================================================================================"
    fi
  done
fi
}

# ffmpeg aliases
fftrim () { #3 arguments, input file, start time, duration
  if [[ "$#" -eq 0 ]]; then
    echo "HOW TO USE: fftrim takes in 3 arguments, input_file.mp3/.mp4, start_time, duration"
    echo "EXAMPLE: fftrim song.mp3 0 1:00     (trims song.mp3 from 0:00 onward, output duration will be 1 minute long"
    echo "EXAMPLE: fftrim video.mp4 0:30 1:00 (trims video.mp4 from 0:30 onward, output duration will be 1 minute long)"
  elif [ "$#" -ne 3 ]; then
    echo "NOTE: fftrim takes in only 3 arguments! input_file.mp3/.mp4, start_time, duration"
  else
    if [[ ${1: -4} == ".mp3" ]]; then
      ffmpeg -i "$1" -ss "$2" -t "$3" -acodec copy -vsync 2 "${1%.mp3}T.mp3";
    elif [[ ${1: -4} == ".mp4" ]]; then
      ffmpeg -i "$1" -ss "$2" -t "$3" -acodec copy -vsync 2 "${1%.mp4}T.mp4";
    else
      echo "file is not an mp3 or mp4!"
    fi
  fi
}
ffadeoutmp3 () { #input file, start of fade, duration of fade
  if [[ "$#" -eq 0 ]]; then
    echo "HOW TO USE: ffadeoutmp3 takes in 3 arguments, input_file.mp3, start_of_fade(only accepts minutes:seconds format), duration_of_fade(how long the fade should be stretched over, in seconds. Everything after the fade will be silenced)"
  elif [ "$#" -ne 3 ]; then
    echo "ffadeoutmp3 takes in only 3 arguments! input_file.mp3, start_of_fade, duration_of_fade"
  else
    minutes=${2%%:*}
    seconds=${2##*:}
    totalseconds=$(($minutes*60 + $seconds))
    echo "$minutes min $seconds sec= $totalseconds sec"
    if [[ ${1: -4} == ".mp3" ]]; then
      # :st= start of fade, :d= duration of fade
      ffmpeg -i "$1" -af "afade=t=out:st='$totalseconds':d='$3'" "${1%.mp3}F.mp3";
    else
      echo "file is not an mp3!"
    fi
  fi
}
ff-convert-to-mp4 () {
if [[ "$#" -eq 0 ]]; then
  echo "HOW TO USE: ff-convert-to-mp4 accepts only TS/flv/mov/avi/mkv/wmv files. It will convert all files provided as arguments that match the first file's filetype"
  echo "EXAMPLE: ff-convert-to-mp4 video1.flv                     (converts video.flv into video.mp4)"
  echo "EXAMPLE: ff-convert-to-mp4 *.flv                          (converts all flv files into mp4)"
  echo "EXAMPLE: ff-convert-to-mp4 video1.TS video2.TS video3.mov (ignores video3.mov because the first file is a .TS)"
elif [[ ${1: -4} == ".mov" ]]; then
  for filename in "$@"; do
    if [[ ${filename: -4} == ".mov" ]]; then
      echo "$filename"
      ffmpeg -i $filename -c copy "${filename%.mov}.mp4";
      echo "----------------------------------------"
    fi
  done
elif [[ ${1: -4} == ".flv" ]]; then
  for filename in "$@"; do
    if [[ ${filename: -4} == ".flv" ]]; then
      echo "$filename"
      ffmpeg -i $filename -codec copy "${filename%.flv}.mp4";
      echo "----------------------------------------"
    fi
  done
elif [[ ${1: -3} == ".TS" ]]; then
  for filename in "$@"; do
    if [[ ${filename: -3} == ".TS" ]]; then
      echo "$filename"
      ffmpeg -i $filename -acodec copy -vcodec copy "${filename%.TS}.mp4";
      echo "----------------------------------------"
    fi
  done
elif [[ ${1: -4} == ".avi" ]]; then
  for filename in "$@"; do
    if [[ ${filename: -4} == ".avi" ]]; then
      echo "$filename"
      ffmpeg -i $filename -c:a aac -b:a 128k -c:v libx264 -crf 23 "${filename%.avi}.mp4";
      echo "----------------------------------------"
    fi
  done
elif [[ ${1: -4} == ".mkv" ]]; then
  for filename in "$@"; do
    if [[ ${filename: -4} == ".mkv" ]]; then
      echo "$filename"
      ffmpeg -i $filename -codec copy  "${filename%.mkv}.mp4";
      echo "----------------------------------------"
    fi
  done
elif [[ ${1: -4} == ".wmv" ]]; then
  for filename in "$@"; do
    if [[ ${filename: -4} == ".wmv" ]]; then
      echo "$filename"
      ffmpeg -i $filename -c:v libx264 -crf 23 -c:a aac -strict -2 -q:a 100 "${filename%.wmv}.mp4";
      echo "----------------------------------------"
    fi
  done
else
  echo "first file is neither a TS, flv or mov file"
fi
}
ff-convert-to-mp3 () {
if [[ "$#" -eq 0 ]]; then
  echo "HOW TO USE: ff-convert-to-mp3 accepts only flac files. It will convert all files provided as arguments that match the first file's filetype"
elif [[ ${1: -5} == ".flac" ]]; then
  for filename in "$@"; do
    if [[ ${1: -5} == ".flac" ]]; then
      echo "$filename"
      ffmpeg -i $filename -ab 320k -map_metadata 0 -id3v2_version 3 "${filename%.flac}.mp3";
      echo "----------------------------------------"
    fi
  done
else
  echo "first file is not a flac file"
fi
}

# Git aliases
alias gac-add-commit-and-push="git add . && git commit && git push origin --all" #stage everything, create new commit and push in one step
alias gak-add-kommit-amend-and-force-push="git add . && git commit --amend --no-edit && git push -f origin --all" #stage & commit everything into previous commit and force push in one step (DO NOT USE FOR SHARED REPOSITORIES)
alias gko-kommit-amend-and-force-push="git commit --amend --no-edit && git push -f origin --all" #commit whatever's been staged into the previous commit and force push in  one step (DO NOT USE FOR SHARED REPOSITORIES)
alias gx="git status"
alias ga="git add"
gco () { #commits all staged files
  git commit -m "$1"
}
gca () { #stages & commits all files
  git commit -am "$1"
}
alias gps="git push"
alias gc="git checkout"
alias gb="git branch"
alias gl="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias glv="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit | vim - +'set nonu' +'set ls=0' +'nnoremap q :qa!<CR>' +'echo(\"[PRESS q TO QUIT]\")'"
alias gsv="git stash save"
alias gsp="git stash pop"
alias gsl="git stash list | vim - +'set nonu' +'set ls=1'"
alias grs="git reset --soft HEAD~1" #soft git commit rollback
alias gdi="git diff | vim -M - +'set nonu' +'set ls=1' +'nnoremap q :qa!<CR>' +'echo(\"[PRESS q TO QUIT]\")'"
gdif () {
  if [[ "$#" -eq 0 ]]; then
    echo "please input a git file to diff"
  else
    git diff "$1" | vim -M - +'set nonu' +'set ls=1' +'nnoremap q :qa!<CR>' +'echo("[PRESS q TO QUIT]")'
  fi
}
gbla () {
  git blame "$@" | vim - +'set nu' +'set ls=1' +'nnoremap q :qa!<CR>' +'echo("[PRESS q TO QUIT]")'
}
alias gnv_open="vim \$(git status --porcelain | awk '{print \$2}')"
#git add --patch <filename> to stage hunks

#tmux aliases
# alias tmux="TERM=screen-256color-bce tmux"
tx () {
  TERM=screen-256color-bce tmux -u new -s "$1"
}
alias txx="TERM=screen-256color-bce tmux -u"
alias txk="TERM=screen-256color-bce tmux -u -L kitty"
alias tls="tmux ls"
alias tax="tmux -u attach-session -t"
alias tks="tmux kill-session -t"
alias tka="tmux kill-server"

# disable flow control
stty -ixon

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
# alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\''\)"'

# export LS_OPTIONS='--color=auto'
# eval "$(dircolors -b)"
# alias ls='ls $LS_OPTIONS'

#LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:'
LS_COLORS='rs=0:di=34:ln=36:mh=00:pi=40;33:so=35:do=35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30:ow=34:st=37;44:ex=32:*.tar=31:*.tgz=31:*.arc=31:*.arj=31:*.taz=31:*.lha=31:*.lz4=31:*.lzh=31:*.lzma=31:*.tlz=31:*.txz=31:*.tzo=31:*.t7z=31:*.zip=31:*.z=31:*.Z=31:*.dz=31:*.gz=31:*.lrz=31:*.lz=31:*.lzo=31:*.xz=31:*.bz2=31:*.bz=31:*.tbz=31:*.tbz2=31:*.tz=31:*.deb=31:*.rpm=31:*.jar=31:*.war=31:*.ear=31:*.sar=31:*.rar=31:*.alz=31:*.ace=31:*.zoo=31:*.cpio=31:*.7z=31:*.rz=31:*.cab=31:*.jpg=35:*.jpeg=35:*.gif=35:*.bmp=35:*.pbm=35:*.pgm=35:*.ppm=35:*.tga=35:*.xbm=35:*.xpm=35:*.tif=35:*.tiff=35:*.png=35:*.svg=35:*.svgz=35:*.mng=35:*.pcx=35:*.mov=35:*.mpg=35:*.mpeg=35:*.m2v=35:*.mkv=35:*.webm=35:*.ogm=35:*.mp4=35:*.m4v=35:*.mp4v=35:*.vob=35:*.qt=35:*.nuv=35:*.wmv=35:*.asf=35:*.rm=35:*.rmvb=35:*.flc=35:*.avi=35:*.fli=35:*.flv=35:*.gl=35:*.dl=35:*.xcf=35:*.xwd=35:*.yuv=35:*.cgm=35:*.emf=35:*.ogv=35:*.ogx=35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:'
export LS_COLORS

#if [ -z "$TMUX" ]; then
#  tmux new-session -A -s o
#fi
