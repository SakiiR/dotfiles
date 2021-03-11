PROXY=$((env | grep -Ei '(http|https)_proxy' > /dev/null) && echo -ne "  ")
hsh=$(hostname|md5|head -c 6|tr -d '\n')

PROMPT='%{$fg[blue]%}${PYENV_VERSION} \
%{$fg[green]%}${PROXY}\
%{$fg[magenta]%}%j%% \
%{$fg[yellow]%}%?! \
%{$fg[cyan]%}$(date +" %h %d %T") \
%{$fg[green]%}%c \
%{$reset_color%}@ \
%{$fg[magenta]%}$hsh \
%{$fg[yellow]%}→ $(git_prompt_info)\
%{$reset_color%}'

ZSH_THEME_GIT_PROMPT_PREFIX="λ %{$fg[blue]%}git %{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$fg[yellow]%} → %{$reset_color%}"
