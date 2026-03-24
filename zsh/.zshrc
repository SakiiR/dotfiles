export ZSH="$HOME/.oh-my-zsh"

DISABLE_UPDATE_PROMPT="true"

# Auto completion
autoload -U compinit
compinit

# Disable pyenv prompt
export PYENV_VIRTUALENV_DISABLE_PROMPT=1

# Disable auto escape :) 
export DISABLE_MAGIC_FUNCTIONS=true

ZSH_THEME="catppuccin"
CATPPUCCIN_FLAVOR="machiato" # Required! Options: mocha, flappe, macchiato, latte
CATPPUCCIN_SHOW_TIME=true

# curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
source ~/.zplug/init.zsh

zplug "plugins/git",   from:oh-my-zsh
zplug "plugins/docker",   from:oh-my-zsh
zplug "plugins/docker-compose",   from:oh-my-zsh
zplug "zsh-users/zsh-syntax-highlighting", defer:2

zplug load --verbose


# Note for me later, docker issues might be because of carapace ;)
plugins=(vi-mode zsh-syntax-highlighting docker docker-compose fzf-tab)

source $ZSH/oh-my-zsh.sh

# Adds sbin
export PATH="$PATH:/usr/local/sbin"
export PATH="$PATH:/usr/sbin"
export PATH="$PATH:/sbin"
export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH:$HOME/.dotnet/tools"
export PATH="$HOME/.poetry/bin:$PATH"
export PATH=$HOME/.cargo/bin/:$PATH
export PATH=$HOME/go/bin:$PATH
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export PATH="$HOME/.npm-global/bin:$PATH"
export PATH="$HOME/.asdf/shims:$PATH"
export GOPATH=$HOME/go

## History configuration
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000000
SAVEHIST=10000000
setopt BANG_HIST                 # Treat the '!' character specially during expansion.
setopt EXTENDED_HISTORY          # Write the history file in the ":start:elapsed;command" format.
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a line previously found.
setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space.
setopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries in the history file.
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording entry.
setopt HIST_VERIFY               # Don't execute immediately upon history expansion.
setopt HIST_BEEP                 # Beep when accessing nonexistent history.

# FZF configuration
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Language
export LANG=fr_FR.UTF-8

# Editor
export EDITOR='vim'

# Aliases
alias ls="eza"
alias l="ls -lA"
alias e="$EDITOR"
alias c="code"
alias cat="bat"
alias ls="eza"
alias l="eza -lhHiuU --icons -a"
alias lt="l -T"
alias lr="l -R"
alias md="mkdir -p"
alias clip='xclip -sel clip'
alias py='python'
alias dc="docker compose"
alias http='http --verify=no'
alias https='http --default-scheme=https --verify=no'
alias httpburp='http --proxy=http:http://127.0.0.1:8080 --proxy=https:http://127.0.0.1:8080'
alias fuzz='ffuf -c -H "User-Agent: test" -of html -t 1 '
alias weather="curl wttr.in"
alias random="head -c 8 /dev/urandom | rax2 -S"
alias render="w3m -T text/html -dump"
alias t="tmux"
alias ipinfo="curl -s ipinfo.io|jq -r '.ip'"
alias x="hexyl"
alias m="cmatrix"
alias g="git"
alias abs="readlink -f"
alias a="readlink -f"


# Functions
timezsh() {
  shell=${1-$SHELL}
  for i in $(seq 1 5); do /usr/bin/time $shell -i -c exit > /dev/null; done
}

rnd() {
  cat /dev/urandom|head -c 64|xxd -p -c0|tr -d '\n'
}

burp() {
  local p="http://127.0.0.1:8080"
  export HTTP_PROXY="${p}"
  export HTTPS_PROXY="${p}"
  export http_proxy="${p}"
  export https_proxy="${p}"
}


unburp() {
  unset HTTP_PROXY
  unset HTTPS_PROXY
  unset http_proxy
  unset https_proxy
}

nmapFast() {
  if [[ -z $1 ]] ; then
    echo "USAGE: nmapFast IP/Domain"
    return
  fi

  item=$1
  item2=$(echo -ne $item|tr '/' '_')

  echo " +++ "
  echo "[±] Starting Fast Nmap Scan for $item"
  echo " +++ "

  nmap -vvv -sTV -Pn -n --top-ports=1000 --reason --open --version-intensity=7 -T4 -oA "${item2}_fast" "$item"
}


nmapFastScript() {
  if [[ -z $1 ]] ; then
    echo "USAGE: nmapFast IP/Domain"
    return
  fi

  item=$1

  echo " +++ "
  echo "[±] Starting Fast Nmap Scan for $item"
  echo " +++ "

  nmap -vvv -n -sC -sV --reason -Pn --version-intensity=3 --top-ports=1000 -oA "${item}_script" "$item"
}


nmapFull() {
  if [[ -z $1 ]] ; then
    echo "USAGE: nmapFull IP/Domain"
    return
  fi

  item=$1
  item2=$(echo $item | tr '/' '_')

  echo " +++ "
  echo "[±] Starting Full Nmap Scan for $item"
  echo " +++ "

  nmap -vvv -sTV -Pn -p- --reason --open --version-intensity=7 --script='*banner,http-enum,http-headers,http-title,*ssl-cert' --script-timeout=1m -T4 -oA "${item2}_full" "$item"
}



nmapLdap() {
  if [[ -z $1 ]] ; then
    echo "USAGE: nmapFull IP/Domain"
    return
  fi

  item=$1
  item2=$(echo $item | tr '/' '_')

  echo " +++ "
  echo "[±] Starting Ldap Nmap Scan for $item"
  echo " +++ "

  nmap --reason -sTV -vvv -p389 --script ldap-search -oA ldap_search -oA "${item2}_full" "$item"
}


nmapUDP() {
  if [[ -z $1 ]] ; then
    echo "USAGE: nmapUDP IP/Domain"
    return
  fi

  item=$1

  echo " +++ "
  echo "[±] Starting UDP Nmap Scan for $item"
  echo " +++ "

  sudo nmap -vvv -n -sUV --reason -Pn -p 43,53,67,68,111,137,138,139,161,500,1434,1604 -oA "${item}_udp_full" "$item"
}

nmapTopTCP() {

  if [[ -z $1 ]] ; then
    echo "USAGE: nmapTopTCP IP/Domain"
    return
  fi

  item=$1

  echo " +++ "
  echo "[±] Starting Top TCP Nmap Scan for $item"
  echo " +++ "

  sudo nmap -vvv -n -sSV -reason -Pn -p 0,7,21,22,23,25,53,79,80,81,82,83,84,85,86,87,88,89,90,111,137,138,139,379,389,390,443,445,446,513,514,548,623,631,636,843,873,902,990,1098,1099,1194,1352,1414,1433,1443,1521,1522,1523,1524,1525,1526,1527,1528,1529,1530,1583,1723,1812,1883,2000,2006,2049,2082,2083,2086,2100,2106,2156,2205,2224,2301,2376,2381,2638,3000,3050,3128,3200,3260,3268,3269,3299,3306,3310,3351,3389,3466,3480,3632,3668,3690,4001,4280,4343,4443,4679,4711,4743,4750,4848,4949,5000,5001,5005,5006,5353,5432,5433,5445,5555,5601,5666,5672,5869,5900,5901,5984,5985,5986,6000,6001,6002,6003,6004,6005,6006,6007,6008,6009,6060,6061,6112,6129,6161,6262,6379,6690,7001,7002,7080,7183,7272,7474,7670,7676,7779,8000,8001,8006,8009,8019,8020,8080,8081,8082,8083,8084,8089,8090,8161,8162,8181,8282,8300,8400,8443,8471,8500,8501,8834,8880,8887,8888,8980,9000,9012,9042,9043,9060,9080,9081,9090,9091,9200,9300,9400,9418,9443,9471,9495,9704,9788,9875,9997,9998,10000,10443,11211,11311,12174,13131,16102,16200,17988,17990,19200,27017,27018,27019,28017,32764,35357,38292,41080,41443,50000,50001,50002,50003,50004,50005,50006,50007,50008,50009,50010,50080,50100,61616 -oA "${item}_top_tcp" "$item"
}


d () {
  date +"%Y-%m-%d_%H-%M"
}

load_env() {
  local env_files=()
  while [[ "$1" == *env* ]]; do
    env_files+=("$1")
    shift
  done

  if [[ $# -eq 0 ]]; then
    echo "No command specified after env files" >&2
    return 1
  fi

  for f in "${env_files[@]}"; do
    if [[ ! -f "$f" ]]; then
      echo "Env file not found: $f" >&2
      return 1
    fi
  done

  (
    set -a

    for f in "${env_files[@]}"; do
      while IFS='=' read -r key value; do
        key="${key#"${key%%[![:space:]]*}"}"
        key="${key%"${key##*[![:space:]]}"}"
        value="${value#"${value%%[![:space:]]*}"}"
        value="${value%"${value##*[![:space:]]}"}"

        [[ -z "$key" || "$key" == \#* ]] && continue

        export "$key"="$value"
      done < <(grep -v '^[[:space:]]*#' "$f" | grep -v '^[[:space:]]*$')
    done

    set +a
    "$@"
  )
}

NOTES_DIR="${HOME}/workspace/notes"

notes () {
  ranger  "$NOTES_DIR"
}

note () {
  name=""
  if [[ ! -z "$1" ]] ; then
    name="$1"

  fi

  mkdir -p "${NOTES_DIR}"

  _date=$(date +"%Y-%m-%d_%H-%M"|tr -d '\n')
  $EDITOR "${NOTES_DIR}/note-${_date}_${name}.md"
}


export CWDFILE="$HOME/.workdir"

setcwd () {
  echo -n "$(pwd)" > "$CWDFILE"
}

cm () {
  git add -A
  git commit -m $1
  git push
}

cwd () {
  CWD=$(cat $CWDFILE)
  echo "$CWD"
}

ccwd () {
  c=$(cwd)
  cd "$c"
}

urldecode () {
  node -e 'process.stdout.write(decodeURIComponent(process.argv[1]));' "$1"
}

urlencode () {
  node -e 'process.stdout.write(encodeURIComponent(process.argv[1]));' "$1"
}

update_discord() {
    DEB_FILE="/tmp/discord-update.deb"
    UPDATE_URL="https://discord.com/api/download/stable?platform=linux&format=deb"

    echo "Downloading DEB file"                             && \
    curl --progress-bar -L "${UPDATE_URL}" -o "${DEB_FILE}" && \
    echo "Downloaded DEB file"                              && \
    sudo apt install -y "${DEB_FILE}" > /dev/null           && \
    echo "Installed DEB file"                               && \
    rm -f "${DEB_FILE}"                                     && \
    echo "Removed DEB file"                                 && \
}

zstyle ':completion:*' menu select

fpath+=~/.zfunc

export DEFAULT_KAFKA_SECURITY_PROTOCOL=PLAINTEXT
export DEFAULT_KAFKA_BROKERS=127.0.0.1:9092
