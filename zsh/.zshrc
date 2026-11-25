export ZSH="$HOME/.oh-my-zsh"

# Auto-detect Wayland socket for terminals launched without Wayland env (e.g. via XWayland)
if [[ -z "$WAYLAND_DISPLAY" ]]; then
  for _wl_sock in /run/user/$(id -u)/wayland-[0-9]*; do
    [[ -S "$_wl_sock" ]] && export WAYLAND_DISPLAY="${_wl_sock##*/}" && break
  done
  unset _wl_sock
fi

# Pull NIRI_SOCKET from systemd user environment when not inherited (e.g. inside tmux)
if [[ -z "$NIRI_SOCKET" ]]; then
  _niri_sock=$(systemctl --user show-environment 2>/dev/null | grep '^NIRI_SOCKET=' | cut -d= -f2-)
  [[ -n "$_niri_sock" ]] && export NIRI_SOCKET="$_niri_sock"
  unset _niri_sock
fi

DISABLE_UPDATE_PROMPT="true"

# Auto completion
autoload -U compinit
fpath+=~/.zfunc

# Disable pyenv prompt
export PYENV_VIRTUALENV_DISABLE_PROMPT=1

# Disable auto escape :) 
export DISABLE_MAGIC_FUNCTIONS=true

ZSH_THEME="catppuccin"
CATPPUCCIN_FLAVOR="mocha" # Options: mocha, frappe, macchiato, latte
CATPPUCCIN_SHOW_TIME=true


# curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
source ~/.zplug/init.zsh

zplug "plugins/git",   from:oh-my-zsh
zplug "plugins/docker",   from:oh-my-zsh
zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "Aloxaf/fzf-tab"

zplug load # --verbose


# Note for me later, docker issues might be because of carapace ;)
plugins=(vi-mode docker)

source $ZSH/oh-my-zsh.sh

ZSH_THEME_GIT_PROMPT_PREFIX="%F{${catppuccin_teal}}"
ZSH_THEME_GIT_PROMPT_DIRTY=" %F{${catppuccin_yellow}}%1{✗%}"
ZSH_THEME_GIT_PROMPT_CLEAN=" %F{${catppuccin_green}}%1{✔%}"

# Adds sbin
export PATH="$PATH:/usr/local/sbin"
export PATH="$PATH:/usr/sbin"
export PATH="$PATH:/sbin"
export PATH="$HOME/.local/bin:$PATH"
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
export LANG=en_US.UTF-8

# Editor
export EDITOR='vim'

# Aliases
alias ls="eza"
alias l="ls -lA"
alias e="$EDITOR"
alias c="code"
(( $+commands[batcat] )) && alias cat="batcat" || alias cat="bat"   # Debian names it batcat
alias ls="eza"
alias l="eza -lhHiuU --icons -a"
alias lt="l -T"
alias lr="l -R"
alias md="mkdir -p"
#alias clip='xclip -sel clip'
alias clip='wl-copy'
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
alias a="abs"
alias cloc="tokei"


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

# goclaude </command> <issue|url|id> [extra prompt...]   worktree named after the reference
# goclaude <prompt...>                                   worktree named by Claude
# Start Claude in a new worktree and send it the prompt.
#   goclaude /plan PROJ-123                                  # worktree proj-123
#   goclaude /ship PROJ-123 only the API part, skip the docs
#   goclaude /mr-review https://gitlab.com/…/-/merge_requests/1234   # worktree mr-1234
#   goclaude /sentry-review https://example.sentry.io/issues/6123456789/   # worktree sentry-6123456789
#   goclaude /sentry-review PROJ-BACK-CC "why now? don't touch migrations"
#   goclaude 'Find why the events consumer lags behind'      # plain prompt, no command
#   goclaude /todo                                           # command without a reference
# Options (first arguments, tmux only):
#   -w, --new-window   run in a new tmux window (tab). The tab always follows the
#                      title Claude sets: the session name (proj-123) in reference
#                      mode, the title Claude picks for a plain prompt.
#   -p, --pane         run in a new tmux pane (side-by-side split) of this window.
#   goclaude -w /plan PROJ-123
#   goclaude -w 'Find why the events consumer lags behind'
# Quote the URL or the prompt when it contains & ; | ( ) ! or an apostrophe.
goclaude() {
    local mode=""
    while [ $# -gt 0 ]; do
        case "$1" in
            -w|--new-window) mode=window; shift ;;
            -p|--pane)       mode=pane;   shift ;;
            *) break ;;
        esac
    done
    if [ $# -eq 0 ]; then
        echo "usage: goclaude [-w|-p] </command> <issue|url|id> [extra prompt...] | goclaude [-w|-p] <prompt...>" >&2
        return 2
    fi
    if [ -n "$mode" ] && [ -z "$TMUX" ]; then
        echo "goclaude: --new-window / --pane need to run inside tmux" >&2
        return 1
    fi
    # Plain prompt, or a command without a reference.
    if [ "${1#/}" = "$1" ] || [ $# -eq 1 ]; then
        _goclaude_launch "$mode" "" --worktree -- "$*"
        return
    fi
    local cmd="$1" ref="$2" name
    shift 2

    case "$ref" in
        */-/merge_requests/*) name="mr-${ref#*/-/merge_requests/}" ;;
        */-/issues/*)         name="issue-${ref#*/-/issues/}" ;;
        */-/work_items/*)     name="issue-${ref#*/-/work_items/}" ;;
        *sentry*/issues/*)    name="sentry-${ref#*/issues/}" ;;
        */browse/*)           name="${ref#*/browse/}" ;;
        *)                    name="$ref" ;;
    esac
    name="${name%%[/?#]*}"                     # keep the id segment only
    name="${name//[^A-Za-z0-9._-]/-}"          # safe for a dir and a git branch
    name="$(printf '%s' "$name" | tr '[:upper:]' '[:lower:]' | tr -s '-' | sed 's/^[-.]*//; s/[-.]*$//')"

    if [ -z "$name" ]; then
        echo "goclaude: cannot derive a worktree name from '$ref'" >&2
        return 1
    fi

    # -n names the Claude session: it becomes the terminal title, so the tmux tab follows it.
    _goclaude_launch "$mode" "$name" -n "$name" --worktree "$name" -- "$cmd $ref${*:+ $*}"
}

# _goclaude_launch <mode> <tab name or ""> <claude args...>
# mode "" runs claude here; "window" / "pane" run it in a new tmux window / pane,
# then keep a shell open there when claude exits.
_goclaude_launch() {
    local mode="$1" name="$2" wid
    shift 2
    if [ -z "$mode" ]; then
        claude "$@"
        return
    fi
    local run="claude ${(j: :)${(q)@}}; exec zsh"
    case "$mode" in
        pane)
            tmux split-window -h -c "$PWD" -- zsh -ic "$run"
            ;;
        window)
            # Tab name always follows the pane title, which Claude keeps updated
            # (session name from -n in reference mode, Claude's own title otherwise).
            wid=$(tmux new-window -P -F '#{window_id}' -c "$PWD" -n "${name:-claude}" -- zsh -ic "$run") || return
            tmux select-pane -t "$wid" -T "${name:-claude}"
            tmux set-option -w -t "$wid" automatic-rename on
            tmux set-option -w -t "$wid" automatic-rename-format '#{pane_title}'
            ;;
    esac
}
alias goclaude='noglob goclaude'   # zsh: a bare URL with ? is not expanded as a glob


zstyle ':completion:*' menu select

_dc() {
    # dc="docker compose"; rewrite words so cobra calls
    # "docker __complete compose ..." not "docker compose __complete ..."
    words=("docker" "compose" "${words[2,-1]}")
    (( CURRENT += 1 ))
    _docker
}
compdef _dc dc

export DEFAULT_KAFKA_SECURITY_PROTOCOL=PLAINTEXT
export DEFAULT_KAFKA_BROKERS=127.0.0.1:9092

PROMPT=$PROMPT'%F{cyan}
 $ %f'

source "$HOME/.config/broot/launcher/bash/br"
